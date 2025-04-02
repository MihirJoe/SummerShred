//
//  WeightLogView.swift
//  SummerShred
//
//  Created by Mihir Joshi on 4/1/25.
//

import SwiftUI
import SwiftData
import Charts

struct WeightLogView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query private var weightLogs: [WeightLog]
    @Query private var users: [User]
    
    @State private var showingAddWeightSheet = false
    @State private var weight: Double = 70.0
    @State private var date = Date()
    
    var userUnitSystem: UnitSystem {
        users.first?.unitSystem ?? .metric
    }
    
    var sortedWeightLogs: [WeightLog] {
        weightLogs.sorted(by: { $0.date < $1.date })
    }
    
    var latestWeight: Double {
        sortedWeightLogs.last?.weight ?? (users.first?.weight ?? 0)
    }
    
    var initialWeight: Double {
        users.first?.weight ?? 0
    }
    
    var weightChange: Double {
        latestWeight - initialWeight
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Current weight card
                    VStack(spacing: 12) {
                        Text("Current Weight")
                            .font(.headline)
                        
                        Text(formatWeight(latestWeight))
                            .font(.system(size: 42, weight: .bold))
                        
                        HStack {
                            Image(systemName: weightChange >= 0 ? "arrow.up" : "arrow.down")
                                .foregroundColor(weightChange >= 0 ? .red : .green)
                            
                            Text(formatWeight(abs(weightChange), showUnit: true))
                                .foregroundColor(weightChange >= 0 ? .red : .green)
                            
                            Text("since start")
                                .foregroundColor(.gray)
                        }
                        .font(.subheadline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.1), radius: 5)
                    .padding(.horizontal)
                    
                    // Weight chart
                    if !sortedWeightLogs.isEmpty {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Weight Trend")
                                    .font(.headline)
                                
                                Spacer()
                                
                                Text(userUnitSystem == .metric ? "(kg)" : "(lb)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                            
                            Chart {
                                ForEach(sortedWeightLogs) { log in
                                    LineMark(
                                        x: .value("Date", log.date),
                                        y: .value("Weight", displayWeight(log.weight))
                                    )
                                    .foregroundStyle(Color.blue)
                                    
                                    PointMark(
                                        x: .value("Date", log.date),
                                        y: .value("Weight", displayWeight(log.weight))
                                    )
                                    .foregroundStyle(Color.blue)
                                }
                            }
                            .frame(height: 250)
                            .padding()
                        }
                        .background(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 5)
                        .padding(.horizontal)
                    }
                    
                    // Weight log list
                    VStack(alignment: .leading) {
                        Text("Weight History")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            ForEach(sortedWeightLogs.reversed()) { log in
                                HStack {
                                    Text(log.date, format: Date.FormatStyle(date: .numeric, time: .omitted))
                                    
                                    Spacer()
                                    
                                    Text(formatWeight(log.weight))
                                        .fontWeight(.medium)
                                }
                                .padding()
                                
                                if log != sortedWeightLogs.first {
                                    Divider()
                                        .padding(.horizontal)
                                }
                            }
                        }
                        .background(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 5)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Weight Tracking")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        weight = userUnitSystem == .metric ? latestWeight : convertToImperial(weight: latestWeight)
                        showingAddWeightSheet = true
                    } label: {
                        Label("Add Weight", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddWeightSheet) {
                addWeightForm
            }
        }
    }
    
    private var addWeightForm: some View {
        NavigationStack {
            Form {
                Section(header: Text("Weight Details")) {
                    HStack {
                        Text(userUnitSystem == .metric ? "Weight (kg)" : "Weight (lb)")
                        Spacer()
                        TextField("Weight", value: $weight, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    DatePicker("Date", selection: $date, in: ...Date(), displayedComponents: .date)
                }
            }
            .navigationTitle("Log Weight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingAddWeightSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        addWeightLog()
                        showingAddWeightSheet = false
                    }
                }
            }
        }
    }
    
    private func addWeightLog() {
        guard let user = users.first else { return }
        
        // Convert weight to metric if needed for storage
        let finalWeight = userUnitSystem == .metric ? weight : convertToMetric(weight: weight)
        
        let weightLog = WeightLog(
            weight: finalWeight,
            date: date,
            user: user
        )
        
        modelContext.insert(weightLog)
    }
    
    // Helper functions for unit conversions and formatting
    private func convertToMetric(weight: Double) -> Double {
        return weight * 0.453592 // lb to kg
    }
    
    private func convertToImperial(weight: Double) -> Double {
        return weight * 2.20462 // kg to lb
    }
    
    private func displayWeight(_ weight: Double) -> Double {
        return userUnitSystem == .metric ? weight : convertToImperial(weight: weight)
    }
    
    private func formatWeight(_ weight: Double, showUnit: Bool = true) -> String {
        if userUnitSystem == .metric {
            return showUnit ? String(format: "%.1f kg", weight) : String(format: "%.1f", weight)
        } else {
            let lbs = convertToImperial(weight: weight)
            return showUnit ? String(format: "%.1f lb", lbs) : String(format: "%.1f", lbs)
        }
    }
}

#Preview {
    WeightLogView()
        .modelContainer(for: [User.self, WeightLog.self], inMemory: true)
} 