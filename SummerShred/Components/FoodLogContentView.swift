import SwiftUI
import SwiftData

struct DailySummarySection: View {
    let colorScheme: ColorScheme
    let totalCaloriesToday: Int
    let dailyCalorieTarget: Int
    let totalProteinToday: Double
    let totalCarbsToday: Double
    let totalFatToday: Double
    @Binding var showingMacroDetails: Bool
    
    var body: some View {
        Section {
            VStack(spacing: 12) {
                // Calories Progress
                HStack {
                    VStack(alignment: .leading) {
                        Text("Calories Today")
                            .font(.headline)
                        Text("\(totalCaloriesToday) / \(dailyCalorieTarget) kcal")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    CircularProgressView(
                        progress: Double(totalCaloriesToday) / Double(dailyCalorieTarget),
                        color: colorScheme == .dark ? .white : .black
                    )
                    .frame(width: 60, height: 60)
                }
                
                // Macros Summary
                if showingMacroDetails {
                    VStack(spacing: 16) {
                        MacroProgressBar(
                            label: "Protein",
                            value: totalProteinToday,
                            color: .blue
                        )
                        
                        MacroProgressBar(
                            label: "Carbs",
                            value: totalCarbsToday,
                            color: .green
                        )
                        
                        MacroProgressBar(
                            label: "Fat",
                            value: totalFatToday,
                            color: .orange
                        )
                    }
                }
                
                Button(action: {
                    withAnimation {
                        showingMacroDetails.toggle()
                    }
                }) {
                    HStack {
                        Text(showingMacroDetails ? "Hide Details" : "Show Details")
                        Image(systemName: showingMacroDetails ? "chevron.up" : "chevron.down")
                    }
                    .font(.subheadline)
                }
            }
            .padding(.vertical, 8)
        }
    }
}

struct MealSection: View {
    let mealType: MealType
    let logs: [FoodLog]
    @Binding var selectedMealType: MealType
    @Binding var showingAddFoodLogSheet: Bool
    let deleteFoodLogs: (MealType, IndexSet) -> Void
    
    var body: some View {
        Section {
            if logs.isEmpty {
                Button(action: {
                    selectedMealType = mealType
                    showingAddFoodLogSheet = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.accentColor)
                        Text("Add \(mealType.rawValue.capitalized)")
                            .foregroundColor(.primary)
                    }
                }
            } else {
                ForEach(logs) { log in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(log.food.name)
                                .font(.headline)
                            Text("\(log.food.servingSize) × \(String(format: "%.1f", log.quantity))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text("\(log.totalCalories) kcal")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
                .onDelete { indices in
                    deleteFoodLogs(mealType, indices)
                }
                
                Button(action: {
                    selectedMealType = mealType
                    showingAddFoodLogSheet = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add More")
                    }
                    .font(.subheadline)
                }
            }
        } header: {
            HStack {
                Text(mealType.rawValue.capitalized)
                Spacer()
                let totalCalories = logs.map({ $0.totalCalories }).reduce(0, +)
                Text("\(totalCalories) kcal")
                    .foregroundColor(.gray)
            }
        }
    }
}

struct AddFoodSheet: View {
    @Binding var isPresented: Bool
    @Binding var selectedFood: Food?
    @Binding var showingNutritionQuery: Bool
    @Binding var showingFoodDatabase: Bool
    @Binding var showingCreateFood: Bool
    @Binding var quantity: Double
    @Binding var selectedMealType: MealType
    let foods: [Food]
    let addFoodLog: () -> Void
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(foods) { food in
                        Button(action: {
                            selectedFood = food
                            quantity = 1.0
                            addFoodLog()
                            isPresented = false
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(food.name)
                                        .foregroundColor(.primary)
                                    Text(food.servingSize)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Text("\(food.calories) kcal")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        showingCreateFood = true
                        isPresented = false
                    }) {
                        Label("Manual Entry", systemImage: "square.and.pencil")
                    }
                    
                    Button(action: {
                        showingNutritionQuery = true
                        isPresented = false
                    }) {
                        Label("Ask AI", systemImage: "sparkles")
                    }
                    
                    Button(action: {
                        showingFoodDatabase = true
                        isPresented = false
                    }) {
                        Label("Food Database", systemImage: "list.bullet")
                    }
                }
            }
            .navigationTitle("Add Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

struct FoodLogContentView: View {
    let colorScheme: ColorScheme
    @Binding var selectedDate: Date
    @Binding var showingMacroDetails: Bool
    @Binding var showingAddFoodLogSheet: Bool
    @Binding var showingNutritionQuery: Bool
    @Binding var showingCreateFood: Bool
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
    
    var body: some View {
        List {
            DailySummarySection(
                colorScheme: colorScheme,
                totalCaloriesToday: totalCaloriesToday,
                dailyCalorieTarget: dailyCalorieTarget,
                totalProteinToday: totalProteinToday,
                totalCarbsToday: totalCarbsToday,
                totalFatToday: totalFatToday,
                showingMacroDetails: $showingMacroDetails
            )
            
            ForEach(MealType.allCases, id: \.self) { mealType in
                MealSection(
                    mealType: mealType,
                    logs: filteredFoodLogs.filter { $0.mealType == mealType },
                    selectedMealType: $selectedMealType,
                    showingAddFoodLogSheet: $showingAddFoodLogSheet,
                    deleteFoodLogs: deleteFoodLogs
                )
            }
        }
        .sheet(isPresented: $showingAddFoodLogSheet) {
            AddFoodSheet(
                isPresented: $showingAddFoodLogSheet,
                selectedFood: $selectedFood,
                showingNutritionQuery: $showingNutritionQuery,
                showingFoodDatabase: $showingFoodDatabase,
                showingCreateFood: $showingCreateFood,
                quantity: $quantity,
                selectedMealType: $selectedMealType,
                foods: foods,
                addFoodLog: addFoodLog
            )
        }
    }
}

struct CircularProgressView: View {
    let progress: Double
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 8)
            
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
            
            Text("\(Int(progress * 100))%")
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

struct MacroProgressBar: View {
    let label: String
    let value: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.subheadline)
                Spacer()
                Text(String(format: "%.1fg", value))
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(color.opacity(0.2))
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: min(CGFloat(value / 100.0) * geometry.size.width, geometry.size.width))
                }
            }
            .frame(height: 8)
            .cornerRadius(4)
        }
    }
} 