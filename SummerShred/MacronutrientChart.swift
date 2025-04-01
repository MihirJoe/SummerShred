import SwiftUI
import Charts

struct MacronutrientChart: View {
    let proteinPercentage: Double
    let carbsPercentage: Double
    let fatPercentage: Double
    
    var body: some View {
        Chart {
            // Protein sector
            SectorMark(
                angle: .value("Protein", proteinPercentage),
                innerRadius: .ratio(0.6)
            )
            .foregroundStyle(.blue)
            .annotation(position: .overlay) {
                Text("\(Int(proteinPercentage))%")
                    .font(.caption)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
            }
            
            // Carbs sector
            SectorMark(
                angle: .value("Carbs", carbsPercentage),
                innerRadius: .ratio(0.6)
            )
            .foregroundStyle(.green)
            .annotation(position: .overlay) {
                Text("\(Int(carbsPercentage))%")
                    .font(.caption)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
            }
            
            // Fat sector
            SectorMark(
                angle: .value("Fat", fatPercentage),
                innerRadius: .ratio(0.6)
            )
            .foregroundStyle(.orange)
            .annotation(position: .overlay) {
                Text("\(Int(fatPercentage))%")
                    .font(.caption)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
            }
        }
        .frame(height: 150)
    }
} 