# Technical Writeup

This document outlines the technical details, assumptions, and design choices for the application.

## System Overview and User Flow

This section documents how a user will interact with the application and how data flows between the mobile app, backend service, and USDA API.

````mermaid
flowchart TD
    A[User opens app] --> B[Search screen]
    B --> C[User enters query]
    C --> D[Backend /foods/search]
    D --> E[Show results list]
    E --> F[Select food item]
    F --> G[Backend /foods/id]
    G --> H[Key Nutrients screen]
````
