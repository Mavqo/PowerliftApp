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
    var gender: Gender = .male
    var equipmentType: EquipmentType = .classic
    
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
         profileImageData: Data? = nil,
         gender: Gender = .male,
         equipmentType: EquipmentType = .classic) {
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
        self.gender = gender
        self.equipmentType = equipmentType
    }
    
    // MARK: - Auto-calculate Athlete Level based on IPF GL Points (Official IPF System)
    mutating func updateAthleteLevel() {
        let ipfGL = calculateIPFGLPoints(
            bodyweight: bodyweight,
            total: squatMax + benchMax + deadliftMax,
            gender: gender,
            equipmentType: equipmentType
        )
        
        // Official IPF GL Points Classification System
        // Based on IPF documentation where 100 = Elite level
        if ipfGL < 70 {
            athleteLevel = .beginner  // Untrained/Beginner
        } else if ipfGL < 80 {
            athleteLevel = .beginner  // Beginner (70-79)
        } else if ipfGL < 90 {
            athleteLevel = .intermediate  // Intermediate (80-89)
        } else if ipfGL < 100 {
            athleteLevel = .advanced  // Advanced (90-99)
        } else {
            athleteLevel = .elite  // Elite (100+)
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

// MARK: - Gender Enum
enum Gender: String, Codable {
    case male = "Male"
    case female = "Female"
}

// MARK: - Equipment Type Enum
enum EquipmentType: String, Codable {
    case classic = "Classic"
    case equipped = "Equipped"
}

// MARK: - IPF GL Points Calculation (Official Formula 2020-2023)
func calculateIPFGLPoints(bodyweight: Double, total: Double, gender: Gender, equipmentType: EquipmentType) -> Double {
    guard bodyweight > 0, total > 0 else { return 0 }
    
    // IPF GL Coefficient Constants (2020-2023)
    let constants: (a: Double, b: Double, c: Double)
    
    switch (gender, equipmentType) {
    case (.male, .classic):
        constants = (a: 1199.72839, b: 1025.18162, c: 0.00921)
    case (.male, .equipped):
        constants = (a: 1236.25115, b: 1449.21864, c: 0.01644)
    case (.female, .classic):
        constants = (a: 610.32796, b: 1045.59282, c: 0.03048)
    case (.female, .equipped):
        constants = (a: 758.63878, b: 949.31382, c: 0.02435)
    }
    
    // Formula: IPF GL = (100 × Total) / (A - B × e^(-C × BWT))
    let denominator = constants.a - constants.b * exp(-constants.c * bodyweight)
    let ipfGL = (100.0 * total) / denominator
    
    return max(0, ipfGL)
}
