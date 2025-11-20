# API Documentation 

## Overview of Responsibilites

The backend uses a FastAPI service that acts as a middleware layer between the Flutter application and the USDA FoodData Central API. It exposes two endpoints, food search and food details. It is responsible for integrating with USDA, normalizing raw API responses, managing API keys, and providing consistent, simplified data back to the frontend. It also includes pagination, error handling, and endpoint documentation.

The backend of this application will use a FastAPI implementation. It will serve as a middleware between the Flutter frontend and the USDA FoodData Central API.

The implementation will expose two endpoints: food search and food details.

The implementation will receive data from USDA responses and normalizes it into simplified structures.

The implementation handles API key management, error handling, and pagination.

## Environment Setup

Information about environment setup will go here.

## Required Endpoints

### Food Search Endpoint

This endpoint will allow the user to search for foods by name. This endpoint is called when the user enters a food name into the search bar and initiates a search. The frontend sends the query (and optional page number) to this endpoint, which retrieves matching food items from the USDA API and returns a simplified, paginated list. The app then displays these results in a scrollable list so the user can browse and select the food item they want more information about.

```
GET /foods/search?query=apple&page=1
```

| Parameter Name  | Type  | Required | Description        |
|-----|-----|-----|---------------|
|query| string | yes | Search term for the food item |
| page | int | no | Page number (defaults to 1) |

<br>

**Sample Request**
````json
{
    "page": 1,
    "pageSize": 20,
    "totalResults": 123,
    "items": [
        {
            "id": 123456,
            "name": "Apple",
            "description": "Apple, raw with skin",
            "brand": "N/A"
        }
    ]
}
````

### Food Details Endpoint 

This endpoint will allow the user to retrieve detailed information about a specific food. This endpoint is called when the user selects a food item from the search results. The frontend extracts the food's `foodId` and sends a request to this endpoint to retrieve the food's detailed nutrient information. Once the backend returns the simplified nutrient data, the app navigates to the Key Nutrients screen and displays it to the user. 

```
GET /foods/{foodId}
```

| Parameter Name | Type | Required | Description |
|-----|-----|-----|-----|
| foodId | int | yes | Unique USDA FoodData Central identifier for the food term.

````json
{
    "id": 123456,
    "name": "Apple",
    "description": "Apple, raw with skin",
    "nutrients": {
        "calories": 95,
        "protein": 0.5,
        "carbs": 25,
        "fat": 0.3,
        "fiber": 4.4
    }
}
````

### Error Handling

The backend includes structured error handling to ensure the mobile application receives clear, predictable responses even when external services fail or invalid input is provided. Each error is returned with an appropriate HTTP status code and consistent JSON error format.

<br>

**Error Responses**
| Status | Description | 
|-----|-----|
|`404` | Food item not found |
| `502` | USDA API failure or unexpected USDA response
| `500` | Internal server error |

Each error will have a structure similar to the following with a message corresponding to what type of error it is:

````json
{
    "Error": "Unable to retrieve data from USDA at this time"
}
````
