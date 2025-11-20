# Frontend Documentation

## Overview

The frontend of the application will be a Flutter app. This Flutter application provides a simple interface for searching food items and viewing their key nutritional information. It communicates with the FastAPI backend to fetch serach results and food details from the USDA FoodData Central API.

## Features

The Flutter application will have the following features allow the user to complete the following actions:
* Search for food items
* View paginated results of the food search in a scrollable list
* Tap a food item to view key nutrient information for it
* Navigate between Search and Details screens
* Basic loading states

## Setup 

1. Download the codebase
2. Navigate to the frontend folder
3. Install Flutter dependencies with `flutter pub get`
4. Run the Flutter app on the target platform (for example, to launch to Chrome run `flutter run -d chrome`)

## User Flow

### Search Flow
1. User enters a food name
2. User presses search
3. App calls the `GET /foods/search` endpoint on the FastAPI backend
4. The results are displayed
5. The usesr taps an item -> navigates to Details

### Details Flow
1. User taps a food item in the food search results
2. App calls `GET /foods/{foodId}`
3. Resuts are displayed
4. User clicks back arrow to return to search

## API Integration

The application will communicate with the FastAPI backend to retrieve a list of food items as well as detailed food item information. 

It will call the `GET /foods/search` endpoint to retrieve a paginated list of food items. 20 food items will be displayed per page.

It will call the `GET /foods/{foodId}` endpoint to retrieve detailed nutrition information for that specific food item. `foodId` represents the USDA FoodData Central API's unique identifier for food items.

## Screens Overview

There will be two screens present in the application. 

### Search Screen
The UI of the search screen will consist of the following components:

| Component Name | Component Type | Component Use |
|-----|-----|-----|
| Search Input | Text Input | The user will enter a food item they want to search for into this field|
| Search Button | Button (submit) | The user will click this after entering a search term into the search input| 
| Results List | Scrollable List | The user will scroll through this list and review the results of their search |

### Details Screen
The UI of the Details Screen will consist of the following components:

| Component Name | Component Type | Component Use |
|-----|-----|-----|
| Food Name | Static Text | Used to let the user know which food they are viewing details for |
| Nutrient Table | Table | Used to allow the user to view the nutrition information in a clean, structured format|
| Back button | Button | The user will click this button after viewing nutrition information to navigate back to the list of search results|
