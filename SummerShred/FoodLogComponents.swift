import SwiftUI
import SwiftData

// Meal sections list
public struct MealSectionsList: View {
    let filteredFoodLogs: [FoodLog]
    @Binding var selectedMealType: MealType
    @Binding var showingAddFoodLogSheet: Bool
    let deleteFoodLogs: (MealType, IndexSet) -> Void
    
    public var body: some View {
        List {
            ForEach(MealType.allCases, id: \.self) { mealType in
                MealSectionView(
                    mealType: mealType,
                    mealLogs: filteredFoodLogs.filter { $0.mealType == mealType },
                    selectedMealType: $selectedMealType,
                    showingAddFoodLogSheet: $showingAddFoodLogSheet,
                    deleteFoodLogs: deleteFoodLogs
                )
            }
        }
    }
    
     init(
        filteredFoodLogs: [FoodLog],
        selectedMealType: Binding<MealType>,
        showingAddFoodLogSheet: Binding<Bool>,
        deleteFoodLogs: @escaping (MealType, IndexSet) -> Void
    ) {
        self.filteredFoodLogs = filteredFoodLogs
        self._selectedMealType = selectedMealType
        self._showingAddFoodLogSheet = showingAddFoodLogSheet
        self.deleteFoodLogs = deleteFoodLogs
    }
}

// Individual meal section
public struct MealSectionView: View {
    let mealType: MealType
    let mealLogs: [FoodLog]
    @Binding var selectedMealType: MealType
    @Binding var showingAddFoodLogSheet: Bool
    let deleteFoodLogs: (MealType, IndexSet) -> Void
    
    public var body: some View {
        Section(header: Text(mealType.rawValue.capitalized)) {
            ForEach(mealLogs) { log in
                HStack {
                    VStack(alignment: .leading) {
                        Text(log.food.name)
                            .font(.headline)
                        Text(String(format: "%.1f × %@", log.quantity, log.food.servingSize))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text("\(log.totalCalories) kcal")
                        .fontWeight(.medium)
                }
                .contextMenu {
                    Button {
                        print("Showing details for: \(log.food.name)")
                    } label: {
                        Label("View Details", systemImage: "info.circle")
                    }
                }
            }
            .onDelete { indexSet in
                deleteFoodLogs(mealType, indexSet)
            }
            
            Button {
                selectedMealType = mealType
                showingAddFoodLogSheet = true
            } label: {
                Label("Add Food", systemImage: "plus")
            }
        }
    }
    
     init(
        mealType: MealType,
        mealLogs: [FoodLog],
        selectedMealType: Binding<MealType>,
        showingAddFoodLogSheet: Binding<Bool>,
        deleteFoodLogs: @escaping (MealType, IndexSet) -> Void
    ) {
        self.mealType = mealType
        self.mealLogs = mealLogs
        self._selectedMealType = selectedMealType
        self._showingAddFoodLogSheet = showingAddFoodLogSheet
        self.deleteFoodLogs = deleteFoodLogs
    }
} 
