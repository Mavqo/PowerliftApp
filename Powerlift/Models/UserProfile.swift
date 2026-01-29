import Foundation

struct UserProfile: Codable {
    var name: String
    var bodyweight: Double
    var squatMax: Double
    var benchMax: Double
    var deadliftMax: Double
    var totalLifted: Double
    var hasCompletedOnboarding: Bool
    
    init(
        name: String = "Atleta",
        bodyweight: Double = 75.0,
        squatMax: Double = 100.0,
        benchMax: Double = 80.0,
        deadliftMax: Double = 120.0,
        totalLifted: Double = 0.0,
        hasCompletedOnboarding: Bool = true
    ) {
        self.name = name
        self.bodyweight = bodyweight
        self.squatMax = squatMax
        self.benchMax = benchMax
        self.deadliftMax = deadliftMax
        self.totalLifted = totalLifted
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }
}
