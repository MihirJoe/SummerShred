//
//  ProfileView.swift
//  SummerShred
//
//  Created by Mihir Joshi on 4/1/25.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    
    @State private var showingAddUserSheet = false
    @State private var name = ""
    @State private var weight = 70.0
    @State private var height = 175.0
    @State private var targetCalories = 2000
    @State private var unitSystem = UnitSystem.metric
    
    var body: some View {
        NavigationStack {
            VStack {
                if let user = users.first {
                    userProfileCard(user: user)
                } else {
                    Text("No profile found")
                        .font(.headline)
                        .padding()
                    
                    Button("Create Profile") {
                        showingAddUserSheet = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .navigationTitle("Profile")
            .sheet(isPresented: $showingAddUserSheet) {
                addUserForm
            }
        }
    }
    
    private var addUserForm: some View {
        NavigationStack {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Name", text: $name)
                    
                    Picker("Units", selection: $unitSystem) {
                        Text("Metric (kg, cm)").tag(UnitSystem.metric)
                        Text("Imperial (lb, in)").tag(UnitSystem.imperial)
                    }
                    
                    HStack {
                        Text(unitSystem == .metric ? "Weight (kg)" : "Weight (lb)")
                        Spacer()
                        TextField("Weight", value: $weight, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text(unitSystem == .metric ? "Height (cm)" : "Height (in)")
                        Spacer()
                        TextField("Height", value: $height, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Daily Calorie Target")
                        Spacer()
                        TextField("Calories", value: $targetCalories, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle("New Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingAddUserSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        addUser()
                        showingAddUserSheet = false
                    }
                }
            }
        }
    }
    
    private func userProfileCard(user: User) -> some View {
        VStack(spacing: 20) {
            Text(user.name)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Weight:")
                        .fontWeight(.medium)
                    Text(formatWeight(user.weight, unitSystem: user.unitSystem))
                }
                
                HStack {
                    Text("Height:")
                        .fontWeight(.medium)
                    Text(formatHeight(user.height, unitSystem: user.unitSystem))
                }
                
                HStack {
                    Text("Daily Calorie Target:")
                        .fontWeight(.medium)
                    Text("\(user.targetCalories)")
                }
                
                HStack {
                    Text("Unit System:")
                        .fontWeight(.medium)
                    Text(user.unitSystem == .metric ? "Metric" : "Imperial")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            Button("Edit Profile") {
                name = user.name
                weight = user.unitSystem == .metric ? user.weight : convertToImperial(weight: user.weight)
                height = user.unitSystem == .metric ? user.height : convertToImperial(height: user.height)
                targetCalories = user.targetCalories
                unitSystem = user.unitSystem
                showingAddUserSheet = true
            }
            .buttonStyle(.bordered)
            .padding(.top)
        }
    }
    
    private func addUser() {
        // Convert measurements if needed
        let finalWeight = unitSystem == .metric ? weight : convertToMetric(weight: weight)
        let finalHeight = unitSystem == .metric ? height : convertToMetric(height: height)
        
        let user = User(
            name: name,
            weight: finalWeight,
            height: finalHeight,
            targetCalories: targetCalories,
            unitSystem: unitSystem
        )
        
        modelContext.insert(user)
    }
    
    // Helper functions for unit conversions
    private func convertToMetric(weight: Double) -> Double {
        return weight * 0.453592 // lb to kg
    }
    
    private func convertToMetric(height: Double) -> Double {
        return height * 2.54 // in to cm
    }
    
    private func convertToImperial(weight: Double) -> Double {
        return weight * 2.20462 // kg to lb
    }
    
    private func convertToImperial(height: Double) -> Double {
        return height * 0.393701 // cm to in
    }
    
    private func formatWeight(_ weight: Double, unitSystem: UnitSystem) -> String {
        if unitSystem == .metric {
            return String(format: "%.1f kg", weight)
        } else {
            return String(format: "%.1f lb", convertToImperial(weight: weight))
        }
    }
    
    private func formatHeight(_ height: Double, unitSystem: UnitSystem) -> String {
        if unitSystem == .metric {
            return String(format: "%.1f cm", height)
        } else {
            let inches = convertToImperial(height: height)
            let feet = Int(inches / 12)
            let remainingInches = inches.truncatingRemainder(dividingBy: 12)
            return String(format: "%d' %.1f\"", feet, remainingInches)
        }
    }
}

#Preview {
    ProfileView()
        .modelContainer(for: User.self, inMemory: true)
} 