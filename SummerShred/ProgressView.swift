//
//  ProgressView.swift
//  SummerShred
//
//  Created by Mihir Joshi on 4/1/25.
//

import SwiftUI
import SwiftData
import Charts

// Renamed from ProgressView to AppProgressView to avoid conflicts
struct AppProgressView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Query private var users: [User]
    @Query private var foodLogs: [FoodLog]
    @Query private var weightLogs: [WeightLog]
    
    @State private var selectedTimeRange: TimeRange = .week
    @State private var selectedMetric: ProgressMetric = .calories
    @State private var selectedDate: Date = Date()
    @State private var showingDailyLog: Bool = false
    
    var userUnitSystem: UnitSystem {
        users.first?.unitSystem ?? .metric
    }
    
    var filteredWeightLogs: [WeightLog] {
        let sortedLogs = weightLogs.sorted(by: { $0.date < $1.date })
        return Array(sortedLogs.suffix(timeRangeValue))
    }
    
    var timeRangeValue: Int {
        switch selectedTimeRange {
        case .week:
            return 7
        case .month:
            return 30
        case .threeMonths:
            return 90
        }
    }
    
    var dateRange: [Date] {
        let calendar = Calendar.current
        let today = DateUtils.getCurrentDay()
        return (0..<timeRangeValue).map { days in
            calendar.date(byAdding: .day, value: -days, to: today)!
        }.reversed()
    }
    
    var groupedFoodLogs: [Date: [FoodLog]] {
        let calendar = Calendar.current
        
        // Group logs by day
        var grouped = [Date: [FoodLog]]()
        
        for date in dateRange {
            let startOfDay = calendar.startOfDay(for: date)
            let nextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            let logsForDay = foodLogs.filter { log in
                log.date >= startOfDay && log.date < nextDay
            }
            
            grouped[startOfDay] = logsForDay
        }
        
        return grouped
    }
    
    var calorieData: [ProgressData] {
        let data = groupedFoodLogs.map { (date, logs) in
            let totalCalories = logs.reduce(0) { $0 + $1.totalCalories }
            return ProgressData(date: date, value: Double(totalCalories))
        }.sorted { $0.date < $1.date }
        
        return data
    }
    
    var proteinData: [ProgressData] {
        let data = groupedFoodLogs.map { (date, logs) in
            let totalProtein = logs.reduce(0.0) { $0 + ($1.food.protein * $1.quantity) }
            return ProgressData(date: date, value: totalProtein)
        }.sorted { $0.date < $1.date }
        
        return data
    }
    
    var carbsData: [ProgressData] {
        let data = groupedFoodLogs.map { (date, logs) in
            let totalCarbs = logs.reduce(0.0) { $0 + ($1.food.carbs * $1.quantity) }
            return ProgressData(date: date, value: totalCarbs)
        }.sorted { $0.date < $1.date }
        
        return data
    }
    
    var fatData: [ProgressData] {
        let data = groupedFoodLogs.map { (date, logs) in
            let totalFat = logs.reduce(0.0) { $0 + ($1.food.fat * $1.quantity) }
            return ProgressData(date: date, value: totalFat)
        }.sorted { $0.date < $1.date }
        
        return data
    }
    
    var weightData: [ProgressData] {
        var result = [ProgressData]()
        let calendar = Calendar.current
        
        // Add weight logs where they exist
        for log in filteredWeightLogs {
            let day = calendar.startOfDay(for: log.date)
            let displayWeight = userUnitSystem == .metric ? log.weight : (log.weight * 2.20462)
            result.append(ProgressData(date: day, value: displayWeight))
        }
        
        return result.sorted { $0.date < $1.date }
    }
    
    var logsForSelectedDay: [FoodLog] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return foodLogs.filter { log in
            log.date >= startOfDay && log.date < endOfDay
        }.sorted { $0.date < $1.date }
    }
    
    var totalCaloriesForSelectedDay: Int {
        logsForSelectedDay.reduce(0) { $0 + $1.totalCalories }
    }
    
    var totalProteinForSelectedDay: Double {
        logsForSelectedDay.reduce(0) { $0 + ($1.food.protein * $1.quantity) }
    }
    
    var totalCarbsForSelectedDay: Double {
        logsForSelectedDay.reduce(0) { $0 + ($1.food.carbs * $1.quantity) }
    }
    
    var totalFatForSelectedDay: Double {
        logsForSelectedDay.reduce(0) { $0 + ($1.food.fat * $1.quantity) }
    }
    
    var weightForSelectedDay: Double? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return weightLogs
            .filter { log in log.date >= startOfDay && log.date < endOfDay }
            .sorted { $0.date > $1.date }
            .first?.weight
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if showingDailyLog {
                        dailyLogView
                    } else {
                        timeRangeSelector
                        
                        metricSelector
                        
                        // Use the extracted chart component
                        ProgressChart(
                            data: currentData,
                            metric: selectedMetric,
                            colorScheme: colorScheme
                        )
                        
                        statisticsSection
                        
                        if selectedMetric == .weight {
                            weightHistorySection
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Progress")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(showingDailyLog ? "Show Progress" : "Daily Log") {
                        showingDailyLog.toggle()
                    }
                }
                
                if showingDailyLog {
                    ToolbarItem(placement: .navigationBarLeading) {
                        DatePicker(
                            "",
                            selection: $selectedDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                    }
                }
            }
        }
    }
    
    private var currentData: [ProgressData] {
        switch selectedMetric {
        case .calories:
            return calorieData
        case .protein:
            return proteinData
        case .carbs:
            return carbsData
        case .fat:
            return fatData
        case .weight:
            return weightData
        }
    }
    
    private var timeRangeSelector: some View {
        Picker("Time Range", selection: $selectedTimeRange) {
            Text("Week").tag(TimeRange.week)
            Text("Month").tag(TimeRange.month)
            Text("3 Months").tag(TimeRange.threeMonths)
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }
    
    private var metricSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                metricButton(title: "Calories", metric: .calories, systemImage: "flame.fill", color: .orange)
                metricButton(title: "Protein", metric: .protein, systemImage: "chart.bar.fill", color: .blue)
                metricButton(title: "Carbs", metric: .carbs, systemImage: "chart.pie.fill", color: .green)
                metricButton(title: "Fat", metric: .fat, systemImage: "drop.fill", color: .yellow)
                metricButton(title: "Weight", metric: .weight, systemImage: "scalemass.fill", color: .purple)
            }
            .padding(.horizontal)
        }
    }
    
    private func metricButton(title: String, metric: ProgressMetric, systemImage: String, color: Color) -> some View {
        Button(action: {
            selectedMetric = metric
        }) {
            VStack {
                Image(systemName: systemImage)
                    .font(.system(size: 16))
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(width: 65, height: 50)
            .padding(.horizontal, 5)
            .background(selectedMetric == metric ? color.opacity(0.2) : (colorScheme == .dark ? Color.black.opacity(0.3) : Color.gray.opacity(0.1)))
            .foregroundColor(selectedMetric == metric ? color : .primary)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(selectedMetric == metric ? color : Color.clear, lineWidth: 2)
            )
        }
    }
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Statistics")
                .font(.headline)
                .padding(.horizontal)
            
            HStack(spacing: 15) {
                statisticCard(
                    title: "Average",
                    value: averageValue ?? 0,
                    color: chartColor,
                    showUnit: true
                )
                
                statisticCard(
                    title: "Highest",
                    value: highestValue ?? 0,
                    color: chartColor,
                    showUnit: true
                )
                
                if selectedMetric == .weight && weightData.count >= 2 {
                    let change = (weightData.last?.value ?? 0) - (weightData.first?.value ?? 0)
                    statisticCard(
                        title: "Change",
                        value: change,
                        color: change > 0 ? .red : .green,
                        showUnit: true,
                        showSign: true
                    )
                } else {
                    statisticCard(
                        title: "Total",
                        value: totalValue ?? 0,
                        color: chartColor,
                        showUnit: true
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var weightHistorySection: some View {
        VStack(alignment: .leading) {
            Text("Weight History")
                .font(.headline)
                .padding(.horizontal)
            
            if filteredWeightLogs.isEmpty {
                Text("No weight logs in the selected period")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(filteredWeightLogs.suffix(5).reversed()) { log in
                    HStack {
                        Text(log.date, format: Date.FormatStyle(date: .numeric, time: .omitted))
                        
                        Spacer()
                        
                        let displayWeight = userUnitSystem == .metric ? log.weight : (log.weight * 2.20462)
                        Text(userUnitSystem == .metric ? 
                            String(format: "%.1f kg", displayWeight) : 
                            String(format: "%.1f lb", displayWeight)
                        )
                        .fontWeight(.medium)
                    }
                    .padding()
                    .background(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.1), radius: 3)
                    .padding(.horizontal)
                }
            }
            
            NavigationLink(destination: WeightLogView()) {
                Text("View All Weight Logs")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
            .buttonStyle(.bordered)
            .padding(.horizontal)
        }
    }
    
    private func statisticCard(title: String, value: Double, color: Color, showUnit: Bool = false, showSign: Bool = false) -> some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            
            if showSign {
                Text((value >= 0 ? "+" : "") + formatValue(value, includeUnit: showUnit))
                    .font(.headline)
                    .foregroundColor(color)
            } else {
                Text(formatValue(value, includeUnit: showUnit))
                    .font(.headline)
                    .foregroundColor(color)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 3)
    }
    
    private var chartTitle: String {
        switch selectedMetric {
        case .calories:
            return "Calories"
        case .protein:
            return "Protein"
        case .carbs:
            return "Carbs"
        case .fat:
            return "Fat"
        case .weight:
            return "Weight"
        }
    }
    
    private var chartUnit: String {
        switch selectedMetric {
        case .calories:
            return "kcal"
        case .protein, .carbs, .fat:
            return "grams"
        case .weight:
            return userUnitSystem == .metric ? "kg" : "lb"
        }
    }
    
    private var chartColor: Color {
        switch selectedMetric {
        case .calories:
            return .orange
        case .protein:
            return .blue
        case .carbs:
            return .green
        case .fat:
            return .yellow
        case .weight:
            return .purple
        }
    }
    
    private var averageValue: Double? {
        guard !currentData.isEmpty else { return nil }
        let sum = currentData.reduce(0) { $0 + $1.value }
        return sum / Double(currentData.count)
    }
    
    private var highestValue: Double? {
        return currentData.map { $0.value }.max()
    }
    
    private var totalValue: Double? {
        guard !currentData.isEmpty else { return nil }
        return currentData.reduce(0) { $0 + $1.value }
    }
    
    private var chartYDomain: ClosedRange<Double>? {
        guard let min = currentData.map({ $0.value }).min(),
              let max = currentData.map({ $0.value }).max() else {
            return nil
        }
        
        // Add some padding
        let padding = (max - min) * 0.1
        return (min - padding)...(max + padding)
    }
    
    private func formatValue(_ value: Double, includeUnit: Bool) -> String {
        switch selectedMetric {
        case .calories:
            return includeUnit ? "\(Int(value)) kcal" : "\(Int(value))"
        case .protein, .carbs, .fat:
            return includeUnit ? String(format: "%.1f g", value) : String(format: "%.1f", value)
        case .weight:
            if userUnitSystem == .metric {
                return includeUnit ? String(format: "%.1f kg", value) : String(format: "%.1f", value)
            } else {
                return includeUnit ? String(format: "%.1f lb", value) : String(format: "%.1f", value)
            }
        }
    }
    
    private var dailyLogView: some View {
        VStack(spacing: 20) {
            // Date header
            Text(selectedDate, format: .dateTime.day().month().year())
                .font(.title)
                .fontWeight(.bold)
            
            // Daily summary card
            dailySummaryCard
            
            // Food logs section
            if !logsForSelectedDay.isEmpty {
                dailyFoodLogsSection
            } else {
                Text("No foods logged on this day")
                    .foregroundColor(.gray)
                    .padding(.top, 20)
            }
        }
    }
    
    private var dailySummaryCard: some View {
        VStack(spacing: 15) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Nutrition Summary")
                        .font(.headline)
                    
                    Text("\(totalCaloriesForSelectedDay) kcal")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                // Weight display
                VStack(alignment: .trailing) {
                    Text("Weight")
                        .font(.headline)
                    
                    if let weight = weightForSelectedDay {
                        let displayWeight = userUnitSystem == .metric ? weight : (weight * 2.20462)
                        let unit = userUnitSystem == .metric ? "kg" : "lb"
                        Text(String(format: "%.1f %@", displayWeight, unit))
                            .font(.title2)
                            .fontWeight(.bold)
                    } else {
                        Text("Not logged")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal)
            
            // Macro breakdown
            HStack(spacing: 20) {
                macroInfo(title: "Protein", value: totalProteinForSelectedDay, color: .blue)
                macroInfo(title: "Carbs", value: totalCarbsForSelectedDay, color: .green)
                macroInfo(title: "Fat", value: totalFatForSelectedDay, color: .orange)
            }
            .padding(.horizontal)
            
            // Macro percentages bar
            if totalCaloriesForSelectedDay > 0 {
                macroPercentagesBar
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5)
        .padding(.horizontal)
    }
    
    private var macroPercentagesBar: some View {
        let proteinCal = totalProteinForSelectedDay * 4
        let carbsCal = totalCarbsForSelectedDay * 4
        let fatCal = totalFatForSelectedDay * 9
        let totalCal = proteinCal + carbsCal + fatCal
        
        let proteinPct = totalCal > 0 ? proteinCal / totalCal : 0
        let carbsPct = totalCal > 0 ? carbsCal / totalCal : 0
        let fatPct = totalCal > 0 ? fatCal / totalCal : 0
        
        return VStack(spacing: 5) {
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: CGFloat(proteinPct) * UIScreen.main.bounds.width * 0.8)
                
                Rectangle()
                    .fill(Color.green)
                    .frame(width: CGFloat(carbsPct) * UIScreen.main.bounds.width * 0.8)
                
                Rectangle()
                    .fill(Color.orange)
                    .frame(width: CGFloat(fatPct) * UIScreen.main.bounds.width * 0.8)
            }
            .frame(height: 10)
            .cornerRadius(5)
            
            HStack {
                Text(String(format: "P: %.0f%%", proteinPct * 100))
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Text(String(format: "C: %.0f%%", carbsPct * 100))
                    .font(.caption)
                    .foregroundColor(.green)
                
                Spacer()
                
                Text(String(format: "F: %.0f%%", fatPct * 100))
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding(.horizontal)
        .padding(.top, 5)
    }
    
    private var dailyFoodLogsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Foods Logged")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(logsForSelectedDay) { foodLog in
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
                            
                            Text("•")
                                .foregroundColor(.gray)
                            
                            Text(foodLog.date, format: .dateTime.hour().minute())
                                .font(.caption)
                                .foregroundColor(.gray)
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
    }
    
    private func macroInfo(title: String, value: Double, color: Color) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(String(format: "%.1f", value))
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
                
                Text("g")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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

enum TimeRange {
    case week
    case month
    case threeMonths
}

enum ProgressMetric {
    case calories
    case protein
    case carbs
    case fat
    case weight
}

struct ProgressData: Identifiable {
    var id = UUID()
    var date: Date
    var value: Double
}

#Preview {
    AppProgressView()
        .modelContainer(for: [User.self, Food.self, FoodLog.self, WeightLog.self], inMemory: true)
} 