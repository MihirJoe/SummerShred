import Foundation

enum DateUtils {
    static func getCurrentDay() -> Date {
        let calendar = Calendar.current
        let now = Date()
        
        // Get the current hour
        let hour = calendar.component(.hour, from: now)
        
        // If it's before 6 AM, use yesterday's date
        if hour < 6 {
            return calendar.date(byAdding: .day, value: -1, to: now) ?? now
        }
        
        return now
    }
    
    static func isCurrentDay(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date, inSameDayAs: getCurrentDay())
    }
    
    static func getStartOfCurrentDay() -> Date {
        let calendar = Calendar.current
        return calendar.startOfDay(for: getCurrentDay())
    }
    
    static func getEndOfCurrentDay() -> Date {
        let calendar = Calendar.current
        let startOfDay = getStartOfCurrentDay()
        return calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
    }
} 