import SwiftUI
import Charts

struct SimpleMacroChart: View {
    let macroPercentages: [MacroPercentage]
    
    var body: some View {
        Chart {
            ForEach(macroPercentages) { macro in
                SectorMark(
                    angle: .value("Percentage", macro.value),
                    innerRadius: .ratio(0.5),
                    angularInset: 1.5
                )
                .cornerRadius(3)
                .foregroundStyle(macro.color)
            }
        }
        .frame(height: 150)
    }
} 