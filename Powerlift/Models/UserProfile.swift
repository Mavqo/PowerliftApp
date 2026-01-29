import Foundation

struct UserProfile: Codable {
    var name: String
    var email: String
    var bodyweight: Double
    var height: Double
    var age: Int
    var athleteLevel: AthleteLevel
    var squatMax: Double
    var benchMax: Double
    var deadliftMax: Double
    var totalLifted: Double
    var hasCompletedOnboarding: Bool
    
    init(name: String = "Atleta",
         email: String = "",
         bodyweight: Double = 75.0,
         height: Double = 175.0,
         age: Int = 0,
         athleteLevel: AthleteLevel = .beginner,
         squatMax: Double = 100.0,
         benchMax: Double = 80.0,
         deadliftMax: Double = 120.0,
         totalLifted: Double = 0.0,
         hasCompletedOnboarding: Bool = false) {
        self.name = name
        self.email = email
        self.bodyweight = bodyweight
        self.height = height
        self.age = age
        self.athleteLevel = athleteLevel
        self.squatMax = squatMax
        self.benchMax = benchMax
        self.deadliftMax = deadliftMax
        self.totalLifted = totalLifted
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }
}
