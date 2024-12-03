//
//  Meal.swift
//  MenuApp
//
//  Created by Dhau Embun Azzahra on 03/12/24.
//

struct Meal: Decodable {
    let strMeal: String?
    let strArea: String?
    let strMealThumb: String?
}

struct MealResponse: Decodable {
    let meals: [Meal]?
}
