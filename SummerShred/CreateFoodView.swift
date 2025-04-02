import SwiftUI
import SwiftData

//struct NutritionPreview: View {
//    let calories: Int
//    let protein: Double
//    let carbs: Double
//    let fat: Double
//    let showDetailedView: Bool
//    
//    var body: some View {
//        VStack(spacing: 15) {
//            Text("Nutrition Summary")
//                .font(.headline)
//            
//            // Calories
//            HStack {
//                Text("Calories")
//                    .fontWeight(.medium)
//                Spacer()
//                Text("\(calories) kcal")
//                    .fontWeight(.bold)
//            }
//            .padding(.bottom, 5)
//            
//            // Macronutrients
//            HStack(alignment: .top, spacing: 0) {
//                VStack(alignment: .leading) {
//                    Text("Protein")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                    Text("\(String(format: "%.1f", protein))g")
//                        .font(.headline)
//                        .foregroundColor(.blue)
//                }
//                .frame(maxWidth: .infinity)
//                
//                VStack(alignment: .leading) {
//                    Text("Carbs")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                    Text("\(String(format: "%.1f", carbs))g")
//                        .font(.headline)
//                        .foregroundColor(.green)
//                }
//                .frame(maxWidth: .infinity)
//                
//                VStack(alignment: .leading) {
//                    Text("Fat")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                    Text("\(String(format: "%.1f", fat))g")
//                        .font(.headline)
//                        .foregroundColor(.orange)
//                }
//                .frame(maxWidth: .infinity)
//            }
//            
//            // Calorie breakdown percentages
//            if calories > 0 {
//                HStack(spacing: 0) {
//                    let proteinCal = protein * 4
//                    let carbsCal = carbs * 4
//                    let fatCal = fat * 9
//                    let totalCal = Double(calories)
//                    
//                    if totalCal > 0 {
//                        Rectangle()
//                            .fill(Color.blue)
//                            .frame(width: max(CGFloat(proteinCal / totalCal) * UIScreen.main.bounds.width * 0.7, 0))
//                        
//                        Rectangle()
//                            .fill(Color.green)
//                            .frame(width: max(CGFloat(carbsCal / totalCal) * UIScreen.main.bounds.width * 0.7, 0))
//                        
//                        Rectangle()
//                            .fill(Color.orange)
//                            .frame(width: max(CGFloat(fatCal / totalCal) * UIScreen.main.bounds.width * 0.7, 0))
//                    }
//                }
//                .frame(height: 8)
//                .cornerRadius(4)
//                
//                // Percentage breakdown
//                HStack {
//                    let proteinCal = protein * 4
//                    let carbsCal = carbs * 4
//                    let fatCal = fat * 9
//                    let totalCal = proteinCal + carbsCal + fatCal
//                    
//                    if totalCal > 0 {
//                        Text("P: \(Int(proteinCal / totalCal * 100))%")
//                            .font(.caption)
//                            .foregroundColor(.blue)
//                        
//                        Spacer()
//                        
//                        Text("C: \(Int(carbsCal / totalCal * 100))%")
//                            .font(.caption)
//                            .foregroundColor(.green)
//                        
//                        Spacer()
//                        
//                        Text("F: \(Int(fatCal / totalCal * 100))%")
//                            .font(.caption)
//                            .foregroundColor(.orange)
//                    }
//                }
//            }
//        }
//        .padding()
//        .background(Color(.systemGray6))
//        .cornerRadius(10)
//        .overlay(
//            RoundedRectangle(cornerRadius: 10)
//                .stroke(Color(.systemGray4), lineWidth: 1)
//        )
//    }
//}

struct CreateFoodView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool
    
    @State private var name: String
    @State private var calories: String
    @State private var protein: String
    @State private var carbs: String
    @State private var fat: String
    @State private var servingSize: String
    
    let addNewFood: (Food) -> Void
    
    init(
        isPresented: Binding<Bool>,
        initialName: String = "",
        initialCalories: String = "",
        initialProtein: String = "",
        initialCarbs: String = "",
        initialFat: String = "",
        initialServingSize: String = "",
        addNewFood: @escaping (Food) -> Void
    ) {
        _isPresented = isPresented
        _name = State(initialValue: initialName)
        _calories = State(initialValue: initialCalories)
        _protein = State(initialValue: initialProtein)
        _carbs = State(initialValue: initialCarbs)
        _fat = State(initialValue: initialFat)
        _servingSize = State(initialValue: initialServingSize)
        self.addNewFood = addNewFood
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Information") {
                    HStack {
                        Text("Name")
                        Spacer()
                        TextField("Food name", text: $name)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Serving Size")
                        Spacer()
                        TextField("e.g. 100g", text: $servingSize)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("Nutrition per Serving") {
                    HStack {
                        Text("Calories")
                        Spacer()
                        TextField("0", text: $calories)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("kcal")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Protein")
                        Spacer()
                        TextField("0.0", text: $protein)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Carbs")
                        Spacer()
                        TextField("0.0", text: $carbs)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Fat")
                        Spacer()
                        TextField("0.0", text: $fat)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                            .foregroundColor(.gray)
                    }
                }
                
                Section {
                    Button("Save Food") {
                        saveFood()
                    }
                    .disabled(!isValid)
                }
            }
            .navigationTitle("Create Food")
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
    
    private var isValid: Bool {
        !name.isEmpty &&
        !servingSize.isEmpty &&
        !calories.isEmpty &&
        !protein.isEmpty &&
        !carbs.isEmpty &&
        !fat.isEmpty &&
        Double(calories) != nil &&
        Double(protein) != nil &&
        Double(carbs) != nil &&
        Double(fat) != nil
    }
    
    private func saveFood() {
        guard let caloriesInt = Int(calories),
              let proteinDouble = Double(protein),
              let carbsDouble = Double(carbs),
              let fatDouble = Double(fat) else {
            return
        }
        
        let food = Food(
            name: name,
            calories: caloriesInt,
            protein: proteinDouble,
            carbs: carbsDouble,
            fat: fatDouble,
            servingSize: servingSize
        )
        
        modelContext.insert(food)
        addNewFood(food)
        isPresented = false
    }
} 
