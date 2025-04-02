//
//  FoodLogView.swift
//  SummerShred
//
//  Created by Mihir Joshi on 4/1/25.
//

import SwiftUI
import SwiftData
import Charts

struct FoodLogView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query private var foodLogs: [FoodLog]
    @Query private var foods: [Food]
    @Query private var users: [User]
    
    @State private var showingAddFoodLogSheet = false
    @State private var showingCreateFood = false
    @State private var selectedFood: Food?
    @State private var quantity = 1.0
    @State private var selectedMealType = MealType.breakfast
    @State private var selectedDate = Date()
    @State private var showingMacroDetails = false
    @State private var showingFoodDatabase = false
    @State private var showingNutritionQuery = false
    
    var filteredFoodLogs: [FoodLog] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return foodLogs.filter { foodLog in
            foodLog.date >= startOfDay && foodLog.date < endOfDay
        }
    }
    
    var totalCaloriesToday: Int {
        filteredFoodLogs.reduce(0) { $0 + $1.totalCalories }
    }
    
    var dailyCalorieTarget: Int {
        users.first?.targetCalories ?? 2000
    }
    
    var totalProteinToday: Double {
        filteredFoodLogs.reduce(0) { $0 + ($1.food.protein * $1.quantity) }
    }
    
    var totalCarbsToday: Double {
        filteredFoodLogs.reduce(0) { $0 + ($1.food.carbs * $1.quantity) }
    }
    
    var totalFatToday: Double {
        filteredFoodLogs.reduce(0) { $0 + ($1.food.fat * $1.quantity) }
    }
    
    var body: some View {
        NavigationStack {
            FoodLogContentView(
                colorScheme: colorScheme,
                selectedDate: $selectedDate,
                showingMacroDetails: $showingMacroDetails,
                showingAddFoodLogSheet: $showingAddFoodLogSheet,
                showingNutritionQuery: $showingNutritionQuery,
                showingCreateFood: $showingCreateFood,
                selectedMealType: $selectedMealType,
                selectedFood: $selectedFood,
                quantity: $quantity,
                showingFoodDatabase: $showingFoodDatabase,
                filteredFoodLogs: filteredFoodLogs,
                totalCaloriesToday: totalCaloriesToday,
                dailyCalorieTarget: dailyCalorieTarget,
                totalProteinToday: totalProteinToday,
                totalCarbsToday: totalCarbsToday,
                totalFatToday: totalFatToday,
                foods: foods,
                addFoodLog: addFoodLog,
                deleteFoodLogs: deleteFoodLogs,
                addNewFood: addNewFood
            )
            .sheet(isPresented: $showingNutritionQuery) {
                NutritionQueryView(onResultAccepted: { result in
                    // Create and save the new food
                    let food = Food(
                        name: result.foodName,
                        calories: result.calories,
                        protein: result.protein,
                        carbs: result.carbs,
                        fat: result.fat,
                        servingSize: result.servingSize
                    )
                    modelContext.insert(food)
                    addNewFood(food: food)
                })
            }
            .sheet(isPresented: $showingCreateFood) {
                CreateFoodView(
                    isPresented: $showingCreateFood,
                    addNewFood: { food in
                        addNewFood(food: food)
                    }
                )
            }
        }
    }
    
    private func addFoodLog() {
        guard let food = selectedFood, let user = users.first else { return }
        
        let foodLog = FoodLog(
            food: food,
            quantity: quantity,
            mealType: selectedMealType,
            date: selectedDate,
            user: user
        )
        
        modelContext.insert(foodLog)
        resetFoodLogForm()
    }
    
    private func resetFoodLogForm() {
        selectedFood = nil
        quantity = 1.0
        selectedMealType = .breakfast
    }
    
    private func deleteFoodLogs(for mealType: MealType, at offsets: IndexSet) {
        let logsForMeal = filteredFoodLogs.filter { $0.mealType == mealType }
        
        for index in offsets {
            modelContext.delete(logsForMeal[index])
        }
    }
    
    private func addNewFood(food: Food) {
        selectedFood = food
        showingAddFoodLogSheet = true
    }
}

struct MacroLabel: View {
    let value: String
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(color)
            Text(value)
                .font(.caption)
        }
    }
}

#Preview {
    FoodLogView()
        .modelContainer(for: [User.self, Food.self, FoodLog.self], inMemory: true)
} 
