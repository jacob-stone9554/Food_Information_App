# Technical Writeup - Food Information Application
Author: Jacob Stone
Date: November 2025

## 1. Project Overview

This project is a full-stack application that integrates a Flutter frontend with a FastAPI backend to fetch and display food and nutrient data from the USDA FoodData Central API.

The goal of this project is to show competency in: 
* Designing a simple backend API service
* Using external APIs securely via environment variables
* Building a functional Flutter Frontend
* Handling pagination, navigation, data models, and TTP requests

### My Approach

The first step in my process was to try and understand who might be using this and why. I came to the conclusion that the most likely user is someone who wants to know more about the food they eat without being overwhelmed with information. As a result, I structured the application in a way that presents nutrition information to the end user without overwhelming them with too much information. When a user views the details of a food item, they will see the name, who makes it, and some nutritional information such as carbs, protein, fat, fiber and sodium contents.

I fully developed the backend of the application first. Once the backend was up and running, I started working on the frontend, getting the UI put together and hooked up to the backend.

### Backend

The backend consists of a FastAPI service ass well as a `usda_client.py` file that handles the integrations with the USSDA FoodData Central API. The backend service returns simplified data to the frontend, the schemas are modeled in `models.py`

### Frontend

The frontend application is a Flutter application. It consists of the main `Food Search` screen where the user can enter a food item to search for. Once a food item has been searched, a list of food items matching that search are displayed. The user can tap a food item from that list to access the `Key Nutrients` screen to view more detailed nutrition information. They can also click the back arrow to navigate back to the `Food Search` page.

## Known Limitationss

I was not able to fully implement all of the features outlined in the requirements. I was able to deliver a functional MVP, but here are some of the limitations of the application I would implement or improve if I had more time:

### 1. Unit and Integration tests
No widget tests or backend tests are implemented due to the time constraint.
In an ideal environment given more time, I would like to add:
* Widget tests for search + results rendering
* API service tests
* Backend FastAPI unit tests

### 2. No State Management

No proper state management was implemented. For a small, demonstrative application this will work, but to ensure that the application scales efficiently as it grows it is critical to get some form of state management in place, like Provider or Riverpod.

3. Basic Error handling. 

The application has very minimal error handling. If more time was available, i would implement more robust error handling, accounting for edge cases and more descriptive error messages.

### 4. No offline caching

Right now, all API calls fetch the latest data. Caching search results in some manner would make the app feel much faster than in currently is. 
