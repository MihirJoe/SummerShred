//
//  DashboardView.swift
//  SummerShred
//
//  Created by Mihir Joshi on 4/1/25.
//

import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Query private var users: [User]
    @Query private var foodLogs: [FoodLog]
    @Query private var weightLogs: [WeightLog]
    
    var todaysFoodLogs: [FoodLog] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return foodLogs.filter { foodLog in
            foodLog.date >= startOfDay && foodLog.date < endOfDay
        }
    }
    
    var totalCaloriesToday: Int {
        todaysFoodLogs.reduce(0) { $0 + $1.totalCalories }
    }
    
    var dailyCalorieTarget: Int {
        users.first?.targetCalories ?? 2000
    }
    
    var caloriesRemaining: Int {
        max(0, dailyCalorieTarget - totalCaloriesToday)
    }
    
    var totalProteinToday: Double {
        todaysFoodLogs.reduce(0) { $0 + ($1.food.protein * $1.quantity) }
    }
    
    var totalCarbsToday: Double {
        todaysFoodLogs.reduce(0) { $0 + ($1.food.carbs * $1.quantity) }
    }
    
    var totalFatToday: Double {
        todaysFoodLogs.reduce(0) { $0 + ($1.food.fat * $1.quantity) }
    }
    
    var macroPercentages: [MacroPercentage] {
        let totalProteinCalories = totalProteinToday * 4 // 4 calories per gram of protein
        let totalCarbsCalories = totalCarbsToday * 4 // 4 calories per gram of carbs
        let totalFatCalories = totalFatToday * 9 // 9 calories per gram of fat
        
        let totalMacroCalories = totalProteinCalories + totalCarbsCalories + totalFatCalories
        
        let proteinPercentage = totalMacroCalories > 0 ? (totalProteinCalories / totalMacroCalories) * 100 : 0
        let carbsPercentage = totalMacroCalories > 0 ? (totalCarbsCalories / totalMacroCalories) * 100 : 0
        let fatPercentage = totalMacroCalories > 0 ? (totalFatCalories / totalMacroCalories) * 100 : 0
        
        return [
            MacroPercentage(name: "Protein", value: proteinPercentage, color: .blue),
            MacroPercentage(name: "Carbs", value: carbsPercentage, color: .green),
            MacroPercentage(name: "Fat", value: fatPercentage, color: .orange)
        ]
    }
    
    var proteinPercentage: Double {
        let proteinCalories = totalProteinToday * 4
        let carbsCalories = totalCarbsToday * 4
        let fatCalories = totalFatToday * 9
        let totalMacroCalories = proteinCalories + carbsCalories + fatCalories
        
        return totalMacroCalories > 0 ? (proteinCalories / totalMacroCalories) * 100 : 0
    }
    
    var carbsPercentage: Double {
        let proteinCalories = totalProteinToday * 4
        let carbsCalories = totalCarbsToday * 4
        let fatCalories = totalFatToday * 9
        let totalMacroCalories = proteinCalories + carbsCalories + fatCalories
        
        return totalMacroCalories > 0 ? (carbsCalories / totalMacroCalories) * 100 : 0
    }
    
    var fatPercentage: Double {
        let proteinCalories = totalProteinToday * 4
        let carbsCalories = totalCarbsToday * 4
        let fatCalories = totalFatToday * 9
        let totalMacroCalories = proteinCalories + carbsCalories + fatCalories
        
        return totalMacroCalories > 0 ? (fatCalories / totalMacroCalories) * 100 : 0
    }
    
    var latestWeight: Double {
        let sortedLogs = weightLogs.sorted(by: { $0.date < $1.date })
        return sortedLogs.last?.weight ?? (users.first?.weight ?? 0)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    welcomeSection
                    calorieSection
                    macroSection
                    todaysFoodSection
                    mealSummarySection
                    weightSection
                }
                .padding(.vertical)
            }
            .navigationTitle("Dashboard")
        }
    }
    
    private var welcomeSection: some View {
        VStack(alignment: .leading) {
            if let user = users.first {
                Text("Welcome, \(user.name)!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Track your progress and stay on target")
                    .foregroundColor(.gray)
            } else {
                Text("Welcome to SummerShred")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Create a profile to get started")
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
    
    private var calorieSection: some View {
        VStack(spacing: 15) {
            Text("Today's Calories")
                .font(.headline)
            
            HStack(spacing: 20) {
                calorieStat(
                    value: totalCaloriesToday,
                    label: "Consumed",
                    color: .blue
                )
                
                calorieStat(
                    value: caloriesRemaining,
                    label: "Remaining",
                    color: .green
                )
                
                calorieStat(
                    value: dailyCalorieTarget,
                    label: "Target",
                    color: .orange
                )
            }
            
            SwiftUI.ProgressView(value: Double(totalCaloriesToday), total: Double(dailyCalorieTarget))
                .tint(calorieProgressColor)
                .padding(.horizontal)
        }
        .padding()
        .background(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5)
        .padding(.horizontal)
    }
    
    private var macroSection: some View {
        VStack(spacing: 15) {
            Text("Macronutrients")
                .font(.headline)
            
            if todaysFoodLogs.isEmpty {
                Text("No food logged today")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                // Use the simpler chart
                SimpleMacroChart(macroPercentages: macroPercentages)
                
                // Macro details
                HStack(spacing: 20) {
                    macroDetailView(
                        title: "Protein",
                        amount: totalProteinToday,
                        percentage: proteinPercentage,
                        color: .blue
                    )
                    
                    macroDetailView(
                        title: "Carbs",
                        amount: totalCarbsToday,
                        percentage: carbsPercentage,
                        color: .green
                    )
                    
                    macroDetailView(
                        title: "Fat",
                        amount: totalFatToday,
                        percentage: fatPercentage,
                        color: .orange
                    )
                }
                .padding(.top, 5)
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5)
        .padding(.horizontal)
    }
    
    private var todaysFoodSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Today's Foods")
                .font(.headline)
                .padding(.horizontal)
            
            if todaysFoodLogs.isEmpty {
                Text("No foods logged today")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                VStack(spacing: 8) {
                    ForEach(todaysFoodLogs) { foodLog in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(foodLog.food.name)
                                    .fontWeight(.medium)
                                
                                HStack(spacing: 4) {
                                    Text("\(String(format: "%.1f", foodLog.quantity)) × \(foodLog.food.servingSize)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                    Text("•")
                                        .foregroundColor(.gray)
                                    
                                    Text(foodLog.mealType.rawValue.capitalized)
                                        .font(.caption)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(mealTypeColor(foodLog.mealType).opacity(0.2))
                                        .cornerRadius(4)
                                }
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("\(foodLog.totalCalories) kcal")
                                    .fontWeight(.medium)
                                
                                HStack(spacing: 8) {
                                    Text("P: \(String(format: "%.1fg", foodLog.food.protein * foodLog.quantity))")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                    
                                    Text("C: \(String(format: "%.1fg", foodLog.food.carbs * foodLog.quantity))")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                    
                                    Text("F: \(String(format: "%.1fg", foodLog.food.fat * foodLog.quantity))")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                        .padding()
                        .background(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 5)
                        .padding(.horizontal)
                    }
                }
                
                NavigationLink(destination: FoodLogView()) {
                    Text("See All in Food Diary")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 8)
                }
                .padding(.top, 5)
            }
        }
    }
    
    private var mealSummarySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Today's Meals")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(MealType.allCases, id: \.self) { mealType in
                let mealLogs = todaysFoodLogs.filter { $0.mealType == mealType }
                let mealCalories = mealLogs.reduce(0) { $0 + $1.totalCalories }
                
                if !mealLogs.isEmpty {
                    NavigationLink(destination: FoodLogView()) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(mealType.rawValue.capitalized)
                                    .fontWeight(.medium)
                                
                                Text("\(mealLogs.count) items")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Text("\(mealCalories) kcal")
                                .fontWeight(.medium)
                        }
                        .padding()
                        .background(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 5)
                        .padding(.horizontal)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            if todaysFoodLogs.isEmpty {
                Text("No meals logged today")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
    }
    
    private var weightSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Current Weight")
                .font(.headline)
                .padding(.horizontal)
            
            NavigationLink(destination: WeightLogView()) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(formatWeight(latestWeight))
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if !weightLogs.isEmpty {
                            Text("Last updated \(weightLogs.sorted(by: { $0.date > $1.date }).first?.date ?? Date(), format: .relative(presentation: .named))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 5)
                .padding(.horizontal)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private func calorieStat(value: Int, label: String, color: Color) -> some View {
        VStack {
            Text("\(value)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func macroDetailView(title: String, amount: Double, percentage: Double, color: Color) -> some View {
        VStack(spacing: 3) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            
            Text(title)
                .font(.footnote)
                .fontWeight(.medium)
            
            Text(String(format: "%.1f g", amount))
                .font(.subheadline)
                .fontWeight(.bold)
            
            Text(String(format: "%.0f%%", percentage))
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var calorieProgressColor: Color {
        let ratio = Double(totalCaloriesToday) / Double(dailyCalorieTarget)
        
        if ratio < 0.7 {
            return .green
        } else if ratio < 1.0 {
            return .yellow
        } else {
            return .red
        }
    }
    
    private func formatWeight(_ weight: Double) -> String {
        let unitSystem = users.first?.unitSystem ?? .metric
        
        if unitSystem == .metric {
            return String(format: "%.1f kg", weight)
        } else {
            let lbs = weight * 2.20462 // Convert kg to lb
            return String(format: "%.1f lb", lbs)
        }
    }
    
    private func mealTypeColor(_ mealType: MealType) -> Color {
        switch mealType {
        case .breakfast:
            return .blue
        case .lunch:
            return .green
        case .dinner:
            return .orange
        case .snack:
            return .purple
        }
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [User.self, Food.self, FoodLog.self, WeightLog.self], inMemory: true)
} 
