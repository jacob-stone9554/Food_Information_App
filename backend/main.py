from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

from models import FoodDetails, LabelNutrients, FoodSummary, SearchResponse
from usda_client import search_foods as usda_search_foods, get_food_by_id as usda_food_by_id, USDAClientError

app = FastAPI(
    title="Food Information API",
    version="1.0.0",
    description="Backend for the Food Information App",
    docs_url="/docs",
    openapi_url="/openapi.json"
)

# this will be restricted to the Flutter app once it is implemented
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)

class FoodItem(BaseModel):
    id: int
    name: str
    calories: int
    protein_g: float
    carbs_g: float
    fat_g: float

class FoodSearchResponse(BaseModel):
    results: list[FoodItem]

# Endpoints

@app.get("/foods", tags=["foods"])
def search_foods(
    query: str = Query(..., description="Search term, e.g. 'apple'"),
    page: int = Query(1, ge=1, description="Page number (1 based)"),
    page_size: int = Query(20, ge=1, le=20, description="Results per page")
):
    try:
        raw = usda_search_foods(query=query, page=page, page_size=page_size)

    except USDAClientError as e: 
        raise HTTPException(status_code=502, detail=str(e))

    foods = [
        FoodSummary(
            fdc_id=item.get("fdcId"),
            description=item.get("description", ""),
            brand_owner=item.get("brandOwner"),
            data_type=item.get("dataType"),
        )
        for item in raw.get("foods", [])
    ]

    return SearchResponse(
        total_hits=raw.get("totalHits", 0),
        current_page=raw.get("currentPage", page),
        total_pages=raw.get("totalPages", 1),
        foods=foods,
    )

@app.get(
    "/food/{fdc_id}",
    response_model=FoodDetails,
    tags=["foods"],
    summary="Get food details by FDC ID",
    description="Returns simplified details for a single food item from USDA FoodData Central.",         
    )
def get_food_details(fdc_id: int):
    try:
        raw = usda_food_by_id(fdc_id)
    except USDAClientError as e:
        if "404" in str(e):
            raise HTTPException(status_code=404, detail="Food not found")
        raise HTTPException(status_code=502, detail=str(e))
    
    ln = raw.get("labelNutrients") or {}

    label_nutrients = LabelNutrients(
        calories=(ln.get("calories") or {}).get("value"),
        fat=(ln.get("fat") or {}).get("value"),
        carbohydrates=(ln.get("carbohydrates") or {}).get("value"),
        sugars=(ln.get("sugars") or {}).get("value"),
        protein=(ln.get("protein") or {}).get("value"),
        sodium=(ln.get("sodium") or {}).get("value"),
    )

    return FoodDetails(
        fdc_id=raw.get("fdcId"),
        description=raw.get("description", ""),
        data_type=raw.get("dataType"),
        brand_owner=raw.get("brandOwner"),
        brand_name=raw.get("brandName"),
        branded_food_category=raw.get("brandedFoodCategory"),
        gtin_upc=raw.get("gtinUpc"),

        serving_size=raw.get("servingSize"),
        serving_size_unit=raw.get("servingSizeUnit"),
        household_serving_full_text=raw.get("householdServingFullText"),
        package_weight=raw.get("packageWeight"),

        ingredients=raw.get("ingredients"),
        nota_significant_source_of=raw.get("notaSignificantSourceOf"),

        label_nutrients=label_nutrients,
    )
    
