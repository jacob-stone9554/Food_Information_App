import os
from typing import Any, Dict

import httpx
from dotenv import load_dotenv

load_dotenv()

USDA_API_KEY = os.getenv("USDA_API_KEY")
USDA_BASE_URL = os.getenv("USDA_BASE_URL", "https://api.nal.usda.gov/fdc/v1")

class USDAClientError(Exception):
    pass

def search_foods(query: str, page: int = 1, page_size: int = 20):
    if not USDA_API_KEY:
        raise USDAClientError("USDA_API_Key is not set. Check your .env file")
    
    url = f"{USDA_BASE_URL}/foods/search"

    payload = {
        "query": query,
        "pageNumber": page,
        "pageSize": page_size,
        "dataType": ["Survery (FNDDS)", "SR Legacy", "Branded"]
    }

    try:
        with httpx.Client(timeout=10.0) as client:
            response = client.post(url, params={"api_key": USDA_API_KEY}, json=payload)
            response.raise_for_status()
            return response.json()
    except httpx.HTTPStatusError as e:
        raise USDAClientError(
            f"USDA Search error: {e.response.status_code} {e.response.text}"
        ) from e
    except httpx.HTTPError as e:
        raise USDAClientError(f"USDA Search error:  {e}") from e
    

def get_food_by_id(fdc_id: int) -> Dict[str, Any]:
        if not USDA_API_KEY:
            raise USDAClientError("USDA_API_KEY is not set. Check your .env file")
        
        url = f"{USDA_BASE_URL}/food/{fdc_id}"

        try:
            with httpx.Client(timeout=10.0) as client:
                response = client.get(url, params={"api_key": USDA_API_KEY})
                response.raise_for_status()
                return response.json()
        except httpx.HTTPStatusError as e:
            raise USDAClientError(f"USDA food details error: {e.response.status_code} {e.response.text}") from e
        except httpx.HTTPError as e:
            raise USDAClientError(f"USDA food details error: {e}") from e

