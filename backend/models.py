from typing import List, Optional
from pydantic import BaseModel

class FoodSummary(BaseModel):
    fdc_id: int
    description: str
    brand_owner: Optional[str] = None
    data_type: Optional[str] = None

class SearchResponse(BaseModel):
    total_hits: int
    current_page: int
    total_pages: int
    foods: List[FoodSummary]

class LabelNutrients(BaseModel):
    calories: Optional[float] = None
    fat: Optional[float] = None
    carbohydrates: Optional[float] = None
    sugars: Optional[float] = None
    protein: Optional[float] = None
    sodium: Optional[float] = None

class FoodDetails(BaseModel):
    fdc_id: int
    description: str
    data_type: Optional[str] = None
    brand_owner: Optional[str] = None
    brand_name: Optional[str] = None
    branded_food_category: Optional[str] = None
    gtin_upc: Optional[str] = None

    serving_size: Optional[float] = None
    serving_size_unit: Optional[str] = None
    household_serving_full_text: Optional[str] = None
    package_weight: Optional[str] = None

    ingredients: Optional[str] = None
    nota_significant_source_of: Optional[str] = None

    label_nutrients: Optional[LabelNutrients] = None