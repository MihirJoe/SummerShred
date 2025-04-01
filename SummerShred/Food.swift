//
//  Food.swift
//  SummerShred
//
//  Created by Mihir Joshi on 4/1/25.
//

import Foundation
import SwiftData

@Model
final class Food {
    var name: String
    var calories: Int
    var protein: Double
    var carbs: Double
    var fat: Double
    var servingSize: String
    
    init(name: String, calories: Int, protein: Double, carbs: Double, fat: Double, servingSize: String) {
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.servingSize = servingSize
    }
} 