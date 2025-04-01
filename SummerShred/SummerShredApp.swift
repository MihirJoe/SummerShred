//
//  SummerShredApp.swift
//  SummerShred
//
//  Created by Mihir Joshi on 4/1/25.
//

import SwiftUI
import SwiftData

@main
struct SummerShredApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            Food.self,
            FoodLog.self,
            WeightLog.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
