import Foundation

enum AthleteLevel: String, Codable, CaseIterable {
    case beginner = "Principiante"
    case intermediate = "Intermedio"
    case advanced = "Avanzato"
    case elite = "Elite"
    
    var displayName: String {
        return self.rawValue
    }
    
    var description: String {
        switch self {
        case .beginner:
            return "0-2 anni di allenamento"
        case .intermediate:
            return "2-5 anni di allenamento"
        case .advanced:
            return "5+ anni di allenamento"
        case .elite:
            return "Atleta competitivo"
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
