import Foundation

struct WorkoutStats: Codable {
    let exerciseType: String
    let avgVelocity: Double
    let maxVelocity: Double
    let rom: Double
    let totalReps: Int
    
    init(exerciseType: String,
         avgVelocity: Double,
         maxVelocity: Double,
         rom: Double,
         totalReps: Int) {
        self.exerciseType = exerciseType
        self.avgVelocity = avgVelocity
        self.maxVelocity = maxVelocity
        self.rom = rom
        self.totalReps = totalReps
    }
}
