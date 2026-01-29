import Foundation

enum ExerciseType: String, Codable, CaseIterable {
    case squat = "Squat"
    case bench = "Bench Press"
    case deadlift = "Deadlift"
    
    var displayName: String {
        return self.rawValue
    }
    
    var emoji: String {
        switch self {
        case .squat:
            return "🏋️"
        case .bench:
            return "💪"
        case .deadlift:
            return "⚡"
        }
    }
    
    var icon: String {
        switch self {
        case .squat:
            return "figure.strengthtraining.traditional"
        case .bench:
            return "figure.strengthtraining.functional"
        case .deadlift:
            return "figure.mixed.cardio"
        }
    }
}
