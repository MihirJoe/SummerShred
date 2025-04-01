//
//  ContentView.swift
//  SummerShred
//
//  Created by Mihir Joshi on 4/1/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if users.isEmpty {
                // Onboarding to create a user profile
                ProfileView()
            } else {
                // Main app content with tabs
                TabView(selection: $selectedTab) {
                    DashboardView()
                        .tabItem {
                            Label("Dashboard", systemImage: "house")
                        }
                        .tag(0)
                    
                    FoodLogView()
                        .tabItem {
                            Label("Food Diary", systemImage: "fork.knife")
                        }
                        .tag(1)
                    
                    AppProgressView()
                        .tabItem {
                            Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                        }
                        .tag(2)
                    
//                    FoodListView()
//                        .tabItem {
//                            Label("Foods", systemImage: "list.bullet")
//                        }
//                        .tag(3)
                    
                    WeightLogView()
                        .tabItem {
                            Label("Weight", systemImage: "scalemass")
                        }
                        .tag(4)
                    
                    ProfileView()
                        .tabItem {
                            Label("Profile", systemImage: "person")
                        }
                        .tag(5)
                }
            }
        }
        .onAppear {
            // Add some sample foods if the database is empty
            Task {
                await addSampleDataIfNeeded()
            }
        }
    }
    
    private func addSampleDataIfNeeded() async {
        let foodsCount = try? modelContext.fetchCount(FetchDescriptor<Food>())
        
        if foodsCount == 0 {
            // Sample foods
            let foods: [(String, Int, Double, Double, Double, String)] = [
                ("Banana", 105, 1.3, 27.0, 0.4, "1 medium (118g)"),
                ("Chicken Breast", 165, 31.0, 0.0, 3.6, "100g"),
                ("Brown Rice", 112, 2.6, 23.5, 0.9, "100g, cooked"),
                ("Egg", 72, 6.3, 0.4, 5.0, "1 large (50g)"),
                ("Broccoli", 55, 3.7, 11.2, 0.6, "100g, cooked"),
                ("Salmon", 208, 20.0, 0.0, 13.0, "100g"),
                ("Greek Yogurt", 59, 10.0, 3.6, 0.4, "100g"),
                ("Avocado", 240, 3.0, 12.0, 22.0, "1 medium (150g)"),
                ("Oatmeal", 154, 6.0, 27.0, 2.6, "100g, cooked"),
                ("Spinach", 23, 2.9, 3.6, 0.4, "100g")
            ]
            
            for (name, calories, protein, carbs, fat, servingSize) in foods {
                let food = Food(
                    name: name,
                    calories: calories,
                    protein: protein,
                    carbs: carbs,
                    fat: fat,
                    servingSize: servingSize
                )
                modelContext.insert(food)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [User.self, Food.self, FoodLog.self, WeightLog.self], inMemory: true)
}
