import Foundation

enum AthleteLevel: String, Codable, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case elite = "Elite"
    
    var displayName: String {
        return self.rawValue
    }
    
    var emoji: String {
        switch self {
        case .beginner:
            return "🌱"
        case .intermediate:
            return "💪"
        case .advanced:
            return "🔥"
        case .elite:
            return "👑"
        }
    }
    
    // Official IPF GL Points ranges
    var description: String {
        switch self {
        case .beginner:
            return "IPF GL: 70-79 Points"
        case .intermediate:
            return "IPF GL: 80-89 Points"
        case .advanced:
            return "IPF GL: 90-99 Points"
        case .elite:
            return "IPF GL: 100+ Points"
        }
    }
    
    var color: String {
        switch self {
        case .beginner:
            return "#4CAF50" // Verde
        case .intermediate:
            return "#2196F3" // Blu
        case .advanced:
            return "#FF9800" // Arancione
        case .elite:
            return "#9C27B0" // Viola
        }
    }
}
