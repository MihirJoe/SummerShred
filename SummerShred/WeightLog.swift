//
//  WeightLog.swift
//  SummerShred
//
//  Created by Mihir Joshi on 4/1/25.
//

import Foundation
import SwiftData

@Model
final class WeightLog {
    var weight: Double
    var date: Date
    var user: User
    
    init(weight: Double, date: Date = Date(), user: User) {
        self.weight = weight
        self.date = date
        self.user = user
    }
} 