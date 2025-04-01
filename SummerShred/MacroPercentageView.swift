import SwiftUI

// Helper struct for macro pie chart
struct MacroPercentage: Identifiable {
    let id = UUID()
    let name: String
    let value: Double
    let color: Color
} 