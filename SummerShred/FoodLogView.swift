//
//  FoodLogView.swift
//  SummerShred
//
//  Created by Mihir Joshi on 4/1/25.
//

import SwiftUI
import SwiftData
import Charts
// Import components from FoodLogComponents

struct FoodLogView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query private var foodLogs: [FoodLog]
    @Query private var foods: [Food]
    @Query private var users: [User]
    
    @State private var showingAddFoodLogSheet = false
    @State private var selectedFood: Food?
    @State private var quantity = 1.0
    @State private var selectedMealType = MealType.breakfast
    @State private var selectedDate = Date()
    @State private var showingMacroDetails = false
    @State private var showingFoodDatabase = false  // New state for showing food database
    
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
        // This method is called after a new food is created and saved to the database
        // It automatically selects the new food and opens the Add Food Log sheet
        selectedFood = food
        showingAddFoodLogSheet = true
    }
}

// Separate content view to reduce complexity
struct FoodLogContentView: View {
    let colorScheme: ColorScheme
    @Binding var selectedDate: Date
    @Binding var showingMacroDetails: Bool
    @Binding var showingAddFoodLogSheet: Bool
    @Binding var selectedMealType: MealType
    @Binding var selectedFood: Food?
    @Binding var quantity: Double
    @Binding var showingFoodDatabase: Bool
    
    let filteredFoodLogs: [FoodLog]
    let totalCaloriesToday: Int
    let dailyCalorieTarget: Int
    let totalProteinToday: Double
    let totalCarbsToday: Double
    let totalFatToday: Double
    let foods: [Food]
    
    let addFoodLog: () -> Void
    let deleteFoodLogs: (MealType, IndexSet) -> Void
    let addNewFood: (Food) -> Void
    
    @State private var searchText = ""
    @State private var showingCreateFoodSheet = false
    @State private var showingTodaysFoods = true  // New state for showing/hiding today's foods
    
    var filteredFoods: [Food] {
        if searchText.isEmpty {
            return foods
        } else {
            return foods.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                // Date picker
                datePickerSection
                
                // Calorie summary card
                calorieSummarySection
                
                // Show today's foods toggle
                if !showingFoodDatabase && !filteredFoodLogs.isEmpty {
                    Button(action: {
                        withAnimation {
                            showingTodaysFoods.toggle()
                        }
                    }) {
                        HStack {
                            Text(showingTodaysFoods ? "Hide Today's Foods" : "Show Today's Foods")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Image(systemName: showingTodaysFoods ? "chevron.up" : "chevron.down")
                        }
                        .padding(.vertical, 5)
                    }
                    .buttonStyle(.borderless)
                }
                
                // Today's foods section
                if !showingFoodDatabase && showingTodaysFoods && !filteredFoodLogs.isEmpty {
                    todaysFoodSection
                }
                
                // Toggle for food database
                HStack {
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            showingFoodDatabase.toggle()
                        }
                    }) {
                        Text(showingFoodDatabase ? "View Food Diary" : "View Food Database")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 5)
                
                if showingFoodDatabase {
                    // Food database section
                    foodDatabaseSection
                } else {
                    // Meal sections
                    mealSectionsView
                }
            }
        }
        .navigationTitle("Food Diary")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddFoodLogSheet = true
                } label: {
                    Label("Add Food", systemImage: "plus.circle.fill")
                }
            }
        }
        .sheet(isPresented: $showingAddFoodLogSheet) {
            AddFoodLogFormView(
                isPresented: $showingAddFoodLogSheet,
                selectedFood: $selectedFood,
                quantity: $quantity,
                selectedMealType: $selectedMealType,
                selectedDate: $selectedDate,
                foods: foods,
                addFoodLog: addFoodLog
            )
        }
        .sheet(isPresented: $showingCreateFoodSheet) {
            CreateFoodView(isPresented: $showingCreateFoodSheet, addNewFood: addNewFood)
        }
    }
    
    private var datePickerSection: some View {
        DatePicker("Date", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
            .datePickerStyle(.compact)
            .padding()
    }
    
    private var calorieSummarySection: some View {
        CalorieSummaryView(
            colorScheme: colorScheme,
            totalCaloriesToday: totalCaloriesToday,
            dailyCalorieTarget: dailyCalorieTarget,
            showingMacroDetails: $showingMacroDetails,
            totalProteinToday: totalProteinToday,
            totalCarbsToday: totalCarbsToday,
            totalFatToday: totalFatToday
        )
    }
    
    private var mealSectionsView: some View {
        MealSectionsList(
            filteredFoodLogs: filteredFoodLogs,
            selectedMealType: $selectedMealType,
            showingAddFoodLogSheet: $showingAddFoodLogSheet,
            deleteFoodLogs: deleteFoodLogs
        )
    }
    
    // New section for food database
    private var foodDatabaseSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Food Database")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.top, 5)
            
            HStack {
                Text("Tap on any food to add it to your diary")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button(action: {
                    showingCreateFoodSheet = true
                }) {
                    Label("Add New", systemImage: "plus.circle")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search foods", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal)
            
            // Results count
            if !searchText.isEmpty {
                Text("\(filteredFoods.count) foods found")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            }
            
            List {
                ForEach(filteredFoods) { food in
                    Button(action: {
                        selectedFood = food
                        showingAddFoodLogSheet = true
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(food.name)
                                    .font(.headline)
                                Text(food.servingSize)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("\(food.calories) kcal")
                                    .fontWeight(.medium)
                                
                                HStack(spacing: 8) {
                                    MacroLabel(value: String(format: "%.1fg", food.protein), color: .blue, label: "P")
                                    MacroLabel(value: String(format: "%.1fg", food.carbs), color: .green, label: "C")
                                    MacroLabel(value: String(format: "%.1fg", food.fat), color: .orange, label: "F")
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(PlainListStyle())
            .frame(minHeight: 400)
        }
        .background(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white.opacity(0.7))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5)
        .padding(.horizontal)
    }
    
    private var todaysFoodSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Today's Foods")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 8) {
                ForEach(filteredFoodLogs) { foodLog in
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
                    .contextMenu {
                        Button(role: .destructive) {
                            // Find the meal type and index to delete this specific food log
                            let mealType = foodLog.mealType
                            if let index = filteredFoodLogs.filter({ $0.mealType == mealType }).firstIndex(where: { $0.id == foodLog.id }) {
                                deleteFoodLogs(mealType, IndexSet([index]))
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .padding(.vertical, 5)
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

// Calorie summary section
struct CalorieSummaryView: View {
    let colorScheme: ColorScheme
    let totalCaloriesToday: Int
    let dailyCalorieTarget: Int
    @Binding var showingMacroDetails: Bool
    let totalProteinToday: Double
    let totalCarbsToday: Double
    let totalFatToday: Double
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Calories Today")
                .font(.headline)
            
            HStack(alignment: .firstTextBaseline) {
                Text("\(totalCaloriesToday)")
                    .font(.system(size: 36, weight: .bold))
                
                Text("/ \(dailyCalorieTarget) kcal")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            SwiftUI.ProgressView(value: Double(totalCaloriesToday), total: Double(dailyCalorieTarget))
                .tint(calorieProgressColor)
                .padding(.horizontal)
            
            Button(action: {
                showingMacroDetails.toggle()
            }) {
                HStack {
                    Text(showingMacroDetails ? "Hide Macros" : "Show Macros")
                        .font(.footnote)
                        .fontWeight(.medium)
                    
                    Image(systemName: showingMacroDetails ? "chevron.up" : "chevron.down")
                        .font(.footnote)
                }
                .padding(.top, 5)
            }
            .buttonStyle(.borderless)
            
            if showingMacroDetails {
                MacronutrientBreakdownView(
                    totalProteinToday: totalProteinToday,
                    totalCarbsToday: totalCarbsToday,
                    totalFatToday: totalFatToday,
                    hasData: totalProteinToday > 0 || totalCarbsToday > 0 || totalFatToday > 0
                )
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5)
        .padding(.horizontal)
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
}

// Macronutrient breakdown view
struct MacronutrientBreakdownView: View {
    let totalProteinToday: Double
    let totalCarbsToday: Double
    let totalFatToday: Double
    let hasData: Bool
    
    var proteinPercentage: Double {
        calculateMacroPercentage(protein: totalProteinToday, carbs: totalCarbsToday, fat: totalFatToday)
    }
    
    var carbsPercentage: Double {
        calculateMacroPercentage(protein: 0, carbs: totalCarbsToday, fat: totalFatToday)
    }
    
    var fatPercentage: Double {
        calculateMacroPercentage(protein: 0, carbs: 0, fat: totalFatToday)
    }
    
    var body: some View {
        VStack {
            HStack {
                macroProgressView(
                    title: "Protein",
                    value: totalProteinToday,
                    color: .blue
                )
                
                macroProgressView(
                    title: "Carbs",
                    value: totalCarbsToday,
                    color: .green
                )
                
                macroProgressView(
                    title: "Fat",
                    value: totalFatToday,
                    color: .orange
                )
            }
            
            if hasData {
                // Use the separated chart component
                MacronutrientChart(
                    proteinPercentage: proteinPercentage,
                    carbsPercentage: carbsPercentage,
                    fatPercentage: fatPercentage
                )
            }
        }
        .padding(.top, 10)
    }
    
    private func macroProgressView(title: String, value: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Text("\(Int(value))g")
                .font(.title3)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func calculateMacroPercentage(protein: Double, carbs: Double, fat: Double) -> Double {
        let proteinCal = protein * 4
        let carbsCal = carbs * 4
        let fatCal = fat * 9
        
        let total = proteinCal + carbsCal + fatCal
        
        if total == 0 {
            return 0
        }
        
        let percentage: Double
        if protein > 0 {
            percentage = (proteinCal / total) * 100
        } else if carbs > 0 {
            percentage = (carbsCal / total) * 100
        } else {
            percentage = (fatCal / total) * 100
        }
        
        return percentage
    }
}

// Add Food Log Form
struct AddFoodLogFormView: View {
    @Binding var isPresented: Bool
    @Binding var selectedFood: Food?
    @Binding var quantity: Double
    @Binding var selectedMealType: MealType
    @Binding var selectedDate: Date
    
    let foods: [Food]
    let addFoodLog: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                // Food Picker Section
                foodPickerSection
                
                // If a food is selected, show additional sections
                if let food = selectedFood {
                    servingSection(food: food)
                    mealTypeSection
                    dateSection
                    nutritionSummarySection(food: food)
                }
            }
            .navigationTitle("Add Food Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarCancelButton
                toolbarSaveButton
            }
        }
    }
    
    private var foodPickerSection: some View {
        Section(header: Text("Select Food")) {
            Picker("Food", selection: $selectedFood) {
                Text("Select a food").tag(nil as Food?)
                ForEach(foods) { food in
                    Text(food.name).tag(food as Food?)
                }
            }
            .pickerStyle(.navigationLink)
        }
    }
    
    private func servingSection(food: Food) -> some View {
        Section(header: Text("Serving")) {
            HStack {
                Text("Quantity")
                Spacer()
                TextField("Quantity", value: $quantity, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
            }
            
            Text("Serving size: \(food.servingSize)")
                .foregroundColor(.gray)
        }
    }
    
    private var mealTypeSection: some View {
        Section(header: Text("Meal")) {
            Picker("Meal", selection: $selectedMealType) {
                ForEach(MealType.allCases, id: \.self) { mealType in
                    Text(mealType.rawValue.capitalized).tag(mealType)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    private var dateSection: some View {
        Section(header: Text("Date & Time")) {
            DatePicker("Date", selection: $selectedDate, in: ...Date(), displayedComponents: [.date, .hourAndMinute])
        }
    }
    
    private var toolbarCancelButton: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
                isPresented = false
            }
        }
    }
    
    private var toolbarSaveButton: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button("Save") {
                addFoodLog()
                isPresented = false
            }
            .disabled(selectedFood == nil)
        }
    }
    
    private func nutritionSummarySection(food: Food) -> some View {
        Section(header: Text("Nutrition Summary")) {
            NutritionRow(label: "Calories", value: "\(Int(Double(food.calories) * quantity)) kcal", isBold: true)
            NutritionRow(label: "Protein", value: String(format: "%.1f g", food.protein * quantity))
            NutritionRow(label: "Carbs", value: String(format: "%.1f g", food.carbs * quantity))
            NutritionRow(label: "Fat", value: String(format: "%.1f g", food.fat * quantity))
        }
    }
}

struct NutritionRow: View {
    let label: String
    let value: String
    var isBold: Bool = false
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .fontWeight(isBold ? .semibold : .regular)
        }
    }
}

extension MealType: CaseIterable {
    static var allCases: [MealType] {
        [.breakfast, .lunch, .dinner, .snack]
    }
}

// Helper view for macronutrient labels in food database
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

// Create Food View
struct CreateFoodView: View {
    @Binding var isPresented: Bool
    let addNewFood: (Food) -> Void
    
    @State private var name = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""
    @State private var servingSize = ""
    @State private var showingPreview = false
    
    @Environment(\.modelContext) private var modelContext
    
    var isFormValid: Bool {
        !name.isEmpty && 
        !servingSize.isEmpty && 
        (Int(calories) ?? 0) > 0 &&
        (Double(protein) ?? 0) >= 0 &&
        (Double(carbs) ?? 0) >= 0 &&
        (Double(fat) ?? 0) >= 0
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Food Name", text: $name)
                    
                    TextField("Serving Size (e.g. '100g' or '1 medium')", text: $servingSize)
                }
                
                Section(header: Text("Nutrition Information")) {
                    HStack {
                        Text("Calories")
                        Spacer()
                        TextField("0", text: $calories)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("kcal")
                    }
                    
                    HStack {
                        Text("Protein")
                        Spacer()
                        TextField("0.0", text: $protein)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                    }
                    
                    HStack {
                        Text("Carbs")
                        Spacer()
                        TextField("0.0", text: $carbs)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                    }
                    
                    HStack {
                        Text("Fat")
                        Spacer()
                        TextField("0.0", text: $fat)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                    }
                }
                
                if showingPreview {
                    Section(header: Text("Preview")) {
                        NutritionPreview(
                            calories: Int(calories) ?? 0,
                            protein: Double(protein) ?? 0,
                            carbs: Double(carbs) ?? 0,
                            fat: Double(fat) ?? 0
                        )
                    }
                }
                
                Section {
                    Button(action: {
                        showingPreview.toggle()
                    }) {
                        HStack {
                            Text(showingPreview ? "Hide Nutrition Preview" : "Show Nutrition Preview")
                            Spacer()
                            Image(systemName: showingPreview ? "chevron.up" : "chevron.down")
                        }
                    }
                }
            }
            .navigationTitle("Create New Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveFood()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    private func saveFood() {
        let newFood = Food(
            name: name,
            calories: Int(calories) ?? 0,
            protein: Double(protein) ?? 0,
            carbs: Double(carbs) ?? 0,
            fat: Double(fat) ?? 0,
            servingSize: servingSize
        )
        
        modelContext.insert(newFood)
        addNewFood(newFood)
        isPresented = false
    }
}

#Preview {
    FoodLogView()
        .modelContainer(for: [User.self, Food.self, FoodLog.self], inMemory: true)
} 
