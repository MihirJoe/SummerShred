import SwiftUI
import Charts




struct ProgressChart: View {
    let data: [ProgressData]
    let metric: ProgressMetric
    let colorScheme: ColorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(chartTitle)
                    .font(.headline)
                
                Spacer()
                
                Text(chartUnit)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            
            if data.isEmpty {
                Text("No data available for the selected time period")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                chart
                    .frame(height: 250)
                    .padding(.horizontal)
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5)
        .padding(.horizontal)
    }
    
    private var chart: some View {
        Chart {
            ForEach(data) { item in
                LineMark(
                    x: .value("Date", item.date),
                    y: .value(metric.description, item.value)
                )
                .foregroundStyle(lineColor)
                
                PointMark(
                    x: .value("Date", item.date),
                    y: .value(metric.description, item.value)
                )
                .foregroundStyle(lineColor)
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: data.count > 14 ? 7 : 1)) { value in
                if let date = value.as(Date.self) {
                    AxisValueLabel {
                        Text(date, format: data.count > 14 ? .dateTime.month().day() : .dateTime.day())
                    }
                }
            }
        }
        .chartYScale(domain: yAxisDomain)
    }
    
    private var chartTitle: String {
        switch metric {
        case .calories:
            return "Calorie Intake"
        case .protein:
            return "Protein Intake"
        case .carbs:
            return "Carbohydrate Intake"
        case .fat:
            return "Fat Intake"
        case .weight:
            return "Weight"
        }
    }
    
    private var chartUnit: String {
        switch metric {
        case .calories:
            return "kcal"
        case .protein, .carbs, .fat:
            return "g"
        case .weight:
            return "kg"
        }
    }
    
    private var lineColor: Color {
        switch metric {
        case .calories:
            return .orange
        case .protein:
            return .blue
        case .carbs:
            return .green
        case .fat:
            return .yellow
        case .weight:
            return .purple
        }
    }
    
    private var yAxisDomain: ClosedRange<Double> {
        if data.isEmpty {
            return 0...100
        }
        
        let min = data.map { $0.value }.min() ?? 0
        let max = data.map { $0.value }.max() ?? 100
        
        // Add some padding so the line doesn't touch the edges
        let padding = (max - min) * 0.1
        return (min - padding)...(max + padding)
    }
}

extension ProgressMetric: CustomStringConvertible {
    var description: String {
        switch self {
        case .calories:
            return "Calories"
        case .protein:
            return "Protein"
        case .carbs:
            return "Carbs"
        case .fat:
            return "Fat"
        case .weight:
            return "Weight"
        }
    }
} 
