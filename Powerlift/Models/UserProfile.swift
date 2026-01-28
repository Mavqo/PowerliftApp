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
    
    init(
        name: String = "Atleta",
        email: String = "",
        bodyweight: Double = 75.0,
        height: Double = 175.0,
        age: Int = 0,
        athleteLevel: AthleteLevel = .beginner,
        squatMax: Double = 100.0,
        benchMax: Double = 80.0,
        deadliftMax: Double = 120.0,
        totalLifted: Double = 0.0,
        hasCompletedOnboarding: Bool = false
    ) {
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
    
    var total: Double {
        return squatMax + benchMax + deadliftMax
    }
    
    var wilksScore: Double? {
        guard bodyweight > 0 else { return nil }
        // Coefficienti per il calcolo Wilks (formula maschile)
        let a: Double = -216.0475144
        let b: Double = 16.2606339
        let c: Double = -0.002388645
        let d: Double = -0.00113732
        let e: Double = 7.01863E-06
        let f: Double = -1.291E-08
        
        let denominator = a + (b * bodyweight) + (c * pow(bodyweight, 2)) + 
                         (d * pow(bodyweight, 3)) + (e * pow(bodyweight, 4)) + 
                         (f * pow(bodyweight, 5))
        
        guard denominator != 0 else { return nil }
        return total * (500 / denominator)
    }
}
