import SwiftUI

struct NutritionPreview: View {
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let showDetailedView: Bool
    
    init(calories: Int, protein: Double, carbs: Double, fat: Double, showDetailedView: Bool = false) {
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.showDetailedView = showDetailedView
    }
    
    var body: some View {
        if showDetailedView {
            detailedView
        } else {
            compactView
        }
    }
    
    private var detailedView: some View {
        VStack(spacing: 15) {
            Text("Nutrition Summary")
                .font(.headline)
            
            // Calories
            HStack {
                Text("Calories")
                    .fontWeight(.medium)
                Spacer()
                Text("\(calories) kcal")
                    .fontWeight(.bold)
            }
            .padding(.bottom, 5)
            
            // Macronutrients
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading) {
                    Text("Protein")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("\(String(format: "%.1f", protein))g")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity)
                
                VStack(alignment: .leading) {
                    Text("Carbs")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("\(String(format: "%.1f", carbs))g")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity)
                
                VStack(alignment: .leading) {
                    Text("Fat")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("\(String(format: "%.1f", fat))g")
                        .font(.headline)
                        .foregroundColor(.orange)
                }
                .frame(maxWidth: .infinity)
            }
            
            // Calorie breakdown percentages
            if calories > 0 {
                HStack(spacing: 0) {
                    let proteinCal = protein * 4
                    let carbsCal = carbs * 4
                    let fatCal = fat * 9
                    let totalCal = Double(calories)
                    
                    if totalCal > 0 {
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: max(CGFloat(proteinCal / totalCal) * UIScreen.main.bounds.width * 0.7, 0))
                        
                        Rectangle()
                            .fill(Color.green)
                            .frame(width: max(CGFloat(carbsCal / totalCal) * UIScreen.main.bounds.width * 0.7, 0))
                        
                        Rectangle()
                            .fill(Color.orange)
                            .frame(width: max(CGFloat(fatCal / totalCal) * UIScreen.main.bounds.width * 0.7, 0))
                    }
                }
                .frame(height: 8)
                .cornerRadius(4)
                
                // Percentage breakdown
                HStack {
                    let proteinCal = protein * 4
                    let carbsCal = carbs * 4
                    let fatCal = fat * 9
                    let totalCal = proteinCal + carbsCal + fatCal
                    
                    if totalCal > 0 {
                        Text("P: \(Int(proteinCal / totalCal * 100))%")
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        Spacer()
                        
                        Text("C: \(Int(carbsCal / totalCal * 100))%")
                            .font(.caption)
                            .foregroundColor(.green)
                        
                        Spacer()
                        
                        Text("F: \(Int(fatCal / totalCal * 100))%")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
    
    private var compactView: some View {
        VStack(spacing: 8) {
            Text("\(calories) kcal")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: 16) {
                macroStat("Protein", value: protein, color: .blue)
                macroStat("Carbs", value: carbs, color: .green)
                macroStat("Fat", value: fat, color: .orange)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func macroStat(_ title: String, value: Double, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(String(format: "%.1fg", value))
                .font(.headline)
                .foregroundColor(color)
        }
    }
} 