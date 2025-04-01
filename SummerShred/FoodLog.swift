//
//  FoodLog.swift
//  SummerShred
//
//  Created by Mihir Joshi on 4/1/25.
//

import Foundation
import SwiftData

enum MealType: String, Codable {
    case breakfast
    case lunch
    case dinner
    case snack
}

@Model
final class FoodLog {
    var food: Food
    var quantity: Double
    var mealType: MealType
    var date: Date
    var user: User
    
    init(food: Food, quantity: Double, mealType: MealType, date: Date = Date(), user: User) {
        self.food = food
        self.quantity = quantity
        self.mealType = mealType
        self.date = date
        self.user = user
    }
    
    var totalCalories: Int {
        return Int(Double(food.calories) * quantity)
    }
} 