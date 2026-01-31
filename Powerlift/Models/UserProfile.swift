import Foundation
import UIKit

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
    var profileImageData: Data?
    
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
         hasCompletedOnboarding: Bool = false,
         profileImageData: Data? = nil) {
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
        self.profileImageData = profileImageData
    }
    
    // MARK: - Auto-calculate Athlete Level based on IPF Points
    mutating func updateAthleteLevel() {
        let ipfPoints = calculateIPFPoints(
            bodyweight: bodyweight,
            total: squatMax + benchMax + deadliftMax,
            isMale: true
        )
        
        // IPF Points classification
        if ipfPoints < 300 {
            athleteLevel = .beginner
        } else if ipfPoints < 450 {
            athleteLevel = .intermediate
        } else if ipfPoints < 550 {
            athleteLevel = .advanced
        } else {
            athleteLevel = .elite
        }
    }
    
    // MARK: - Profile Image Helper
    var profileImage: UIImage? {
        get {
            guard let data = profileImageData else { return nil }
            return UIImage(data: data)
        }
        set {
            profileImageData = newValue?.jpegData(compressionQuality: 0.8)
        }
    }
}

// MARK: - IPF Points Calculation (GL Points Formula)
func calculateIPFPoints(bodyweight: Double, total: Double, isMale: Bool) -> Double {
    guard bodyweight > 0, total > 0 else { return 0 }
    
    let bw = bodyweight
    let coefficients: [Double]
    
    if isMale {
        // Men's coefficients (IPF GL Points)
        coefficients = [1199.72839, 1025.18162, 0.00921]
    } else {
        // Women's coefficients (IPF GL Points)
        coefficients = [610.32796, 1045.59282, 0.03048]
    }
    
    let a = coefficients[0]
    let b = coefficients[1]
    let c = coefficients[2]
    
    let denominator = a - b * exp(-c * bw)
    let ipfPoints = 500 + 100 * (total - denominator) / denominator
    
    return max(0, ipfPoints)
}
