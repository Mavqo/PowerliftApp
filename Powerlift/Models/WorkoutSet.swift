import Foundation

struct WorkoutSet: Codable, Identifiable {
    let id: UUID
    var setNumber: Int  // 🔧 QUESTO È IMPORTANTE!
    var weight: Double
    var reps: Int
    var rpe: Double?
    var velocity: Double?
    var rom: Double?
    var date: Date
    
    init(
        setNumber: Int,
        weight: Double,
        reps: Int,
        rpe: Double? = nil,
        velocity: Double? = nil,
        rom: Double? = nil,
        date: Date = Date()
    ) {
        self.id = UUID()
        self.setNumber = setNumber
        self.weight = weight
        self.reps = reps
        self.rpe = rpe
        self.velocity = velocity
        self.rom = rom
        self.date = date
    }
    
    var volume: Double {
        return weight * Double(reps)
    }

    var estimatedOneRepMax: Double {
        guard reps > 0 else { return weight }
        return weight * (1 + Double(reps) / 30)
    }
}
