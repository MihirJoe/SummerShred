import Foundation

struct NutritionQueryResult {
    let foodName: String
    let servingSize: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let confidence: Double
    let source: String
    
    var isHighConfidence: Bool {
        confidence >= 0.8
    }
}

enum NutritionQueryError: Error {
    case invalidResponse
    case lowConfidence
    case networkError
    case parsingError
    
    var message: String {
        switch self {
        case .invalidResponse:
            return "Could not understand the response. Please try rephrasing your question."
        case .lowConfidence:
            return "The AI is not very confident about these values. Please verify them."
        case .networkError:
            return "Could not connect to the AI. Please check your connection and try again."
        case .parsingError:
            return "Could not parse the nutrition information. Please try again."
        }
    }
} 