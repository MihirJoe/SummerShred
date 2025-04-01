//
//  User.swift
//  SummerShred
//
//  Created by Mihir Joshi on 4/1/25.
//

import Foundation
import SwiftData

enum UnitSystem: String, Codable {
    case metric
    case imperial
}

@Model
final class User {
    var name: String
    var weight: Double
    var height: Double
    var targetCalories: Int
    var createdAt: Date
    var unitSystem: UnitSystem
    
    init(name: String, weight: Double, height: Double, targetCalories: Int, unitSystem: UnitSystem = .metric, createdAt: Date = Date()) {
        self.name = name
        self.weight = weight
        self.height = height
        self.targetCalories = targetCalories
        self.unitSystem = unitSystem
        self.createdAt = createdAt
    }
} 