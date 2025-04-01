//
//  FoodListView.swift
//  SummerShred
//
//  Created by Mihir Joshi on 4/1/25.
//

import SwiftUI
import SwiftData

struct FoodListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var foods: [Food]
    
    @State private var showingAddFoodSheet = false
    @State private var name = ""
    @State private var calories = 0
    @State private var protein = 0.0
    @State private var carbs = 0.0
    @State private var fat = 0.0
    @State private var servingSize = ""
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(foods) { food in
                    NavigationLink {
                        FoodDetailView(food: food)
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(food.name)
                                    .font(.headline)
                                Text("\(food.servingSize)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Text("\(food.calories) kcal")
                                .fontWeight(.medium)
                        }
                    }
                }
                .onDelete(perform: deleteFood)
            }
            .navigationTitle("Food Database")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddFoodSheet = true
                    } label: {
                        Label("Add Food", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddFoodSheet) {
                addFoodForm
            }
        }
    }
    
    private var addFoodForm: some View {
        NavigationStack {
            Form {
                Section(header: Text("Food Details")) {
                    TextField("Food Name", text: $name)
                    TextField("Serving Size (e.g. 100g)", text: $servingSize)
                    
                    HStack {
                        Text("Calories")
                        Spacer()
                        TextField("Calories", value: $calories, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section(header: Text("Macronutrients (g)")) {
                    HStack {
                        Text("Protein")
                        Spacer()
                        TextField("Protein", value: $protein, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Carbs")
                        Spacer()
                        TextField("Carbs", value: $carbs, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Fat")
                        Spacer()
                        TextField("Fat", value: $fat, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle("Add Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingAddFoodSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        addFood()
                        showingAddFoodSheet = false
                    }
                }
            }
        }
    }
    
    private func addFood() {
        let food = Food(name: name, calories: calories, protein: protein, carbs: carbs, fat: fat, servingSize: servingSize)
        modelContext.insert(food)
        resetFoodForm()
    }
    
    private func resetFoodForm() {
        name = ""
        calories = 0
        protein = 0.0
        carbs = 0.0
        fat = 0.0
        servingSize = ""
    }
    
    private func deleteFood(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(foods[index])
        }
    }
}

struct FoodDetailView: View {
    let food: Food
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(food.name)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 5)
            
            Text("Serving size: \(food.servingSize)")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 15) {
                nutritionRow(label: "Calories", value: "\(food.calories) kcal")
                Divider()
                nutritionRow(label: "Protein", value: String(format: "%.1f g", food.protein))
                Divider()
                nutritionRow(label: "Carbs", value: String(format: "%.1f g", food.carbs))
                Divider()
                nutritionRow(label: "Fat", value: String(format: "%.1f g", food.fat))
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Food Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func nutritionRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.headline)
            Spacer()
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    FoodListView()
        .modelContainer(for: Food.self, inMemory: true)
} 