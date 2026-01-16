import Foundation

struct Workout: Codable, Identifiable {
    let id: UUID
    var name: String
    var date: Date
    var exerciseType: String
    var sets: [WorkoutSet]
    var notes: String?
    
    init(
        name: String,
        date: Date = Date(),
        exerciseType: String,
        sets: [WorkoutSet] = [],
        notes: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.date = date
        self.exerciseType = exerciseType
        self.sets = sets
        self.notes = notes
    }
    
    var totalVolume: Double {
        return sets.reduce(0.0) { total, set in
            total + (set.weight * Double(set.reps))
        }
    }
    
    var totalSets: Int {
        return sets.count
    }
}
