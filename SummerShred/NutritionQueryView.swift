import SwiftUI

struct NutritionQueryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var queryText = ""
    @State private var isLoading = false
    @State private var error: NutritionQueryError?
    @State private var showingError = false
    @State private var result: NutritionQueryResult?
    @State private var showingCreateFood = false
    
    let onResultAccepted: (NutritionQueryResult) -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Query input section
                queryInputSection
                
                if isLoading {
                    loadingView
                } else if let result = result {
                    resultPreview(result)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Ask AI")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showingError, presenting: error) { _ in
                Button("OK") {}
            } message: { error in
                Text(error.message)
            }
            .sheet(isPresented: $showingCreateFood) {
                if let result = result {
                    CreateFoodView(
                        isPresented: $showingCreateFood,
                        initialName: result.foodName,
                        initialCalories: String(result.calories),
                        initialProtein: String(format: "%.1f", result.protein),
                        initialCarbs: String(format: "%.1f", result.carbs),
                        initialFat: String(format: "%.1f", result.fat),
                        initialServingSize: result.servingSize,
                        addNewFood: { food in
                            onResultAccepted(result)
                            dismiss()
                        }
                    )
                }
            }
        }
    }
    
    private var queryInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ask about any food's nutrition")
                .font(.headline)
            
            Text("Example: \"What are the macros for 200g of chicken breast?\"")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack {
                TextField("Enter your question...", text: $queryText)
                    .textFieldStyle(.roundedBorder)
                
                Button(action: submitQuery) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title2)
                }
                .disabled(queryText.isEmpty || isLoading)
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Analyzing nutrition information...")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func resultPreview(_ result: NutritionQueryResult) -> some View {
        VStack(spacing: 16) {
            // Confidence indicator
            HStack {
                Image(systemName: result.isHighConfidence ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundColor(result.isHighConfidence ? .green : .orange)
                Text(result.isHighConfidence ? "High confidence result" : "Moderate confidence - please verify")
                    .font(.subheadline)
                    .foregroundColor(result.isHighConfidence ? .green : .orange)
            }
            
            // Result card
            VStack(spacing: 12) {
                Text(result.foodName)
                    .font(.headline)
                
                Text(result.servingSize)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Divider()
                
                // Macros grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    macroItem("Calories", value: "\(result.calories)", unit: "kcal")
                    macroItem("Protein", value: String(format: "%.1f", result.protein), unit: "g")
                    macroItem("Carbs", value: String(format: "%.1f", result.carbs), unit: "g")
                    macroItem("Fat", value: String(format: "%.1f", result.fat), unit: "g")
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
            
            // Source attribution
            Text("Source: \(result.source)")
                .font(.caption)
                .foregroundColor(.gray)
            
            // Action buttons
            HStack(spacing: 16) {
                Button(action: {
                    queryText = ""
                    self.result = nil
                }) {
                    Text("Try Another")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                Button(action: {
                    showingCreateFood = true
                }) {
                    Text("Create Food")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.top)
        }
    }
    
    private func macroItem(_ title: String, value: String, unit: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.headline)
            Text(unit)
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }
    
    private func submitQuery() {
        isLoading = true
        error = nil
        
        // Simulate API call with sample data
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if queryText.lowercased().contains("chicken") {
                self.result = NutritionQueryResult(
                    foodName: "Chicken Breast",
                    servingSize: "200g",
                    calories: 330,
                    protein: 62.0,
                    carbs: 0.0,
                    fat: 7.2,
                    confidence: 0.95,
                    source: "USDA Database"
                )
            } else {
                error = .invalidResponse
                showingError = true
            }
            isLoading = false
        }
    }
} 
