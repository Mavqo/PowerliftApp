import Foundation

struct WorkoutPlan: Codable, Identifiable {
    let id: UUID
    let date: Date
    let exerciseType: ExerciseType
    let sets: [PlannedSet]
    let warmupRequired: Bool
    let notes: String?
    var completed: Bool
    var actualSets: [WorkoutSet]?
    
    init(
        date: Date,
        exerciseType: ExerciseType,
        sets: [PlannedSet],
        warmupRequired: Bool = true,
        notes: String? = nil
    ) {
        self.id = UUID()
        self.date = date
        self.exerciseType = exerciseType
        self.sets = sets
        self.warmupRequired = warmupRequired
        self.notes = notes
        self.completed = false
        self.actualSets = nil
    }
    
    var totalVolume: Double {
        sets.reduce(0.0) { total, set in
            let weight = set.weight ?? 0
            return total + (weight * Double(set.reps))
        }
    }
    
    var totalSets: Int {
        sets.count
    }
}

struct PlannedSet: Codable, Identifiable {
    let id: UUID
    let setNumber: Int
    let weight: Double?
    let percentage: Int?
    let reps: Int
    let targetRPE: Double?
    let restSeconds: Int?
    
    init(
        setNumber: Int,
        weight: Double? = nil,
        percentage: Int? = nil,
        reps: Int,
        targetRPE: Double? = nil,
        restSeconds: Int? = 120
    ) {
        self.id = UUID()
        self.setNumber = setNumber
        self.weight = weight
        self.percentage = percentage
        self.reps = reps
        self.targetRPE = targetRPE
        self.restSeconds = restSeconds
    }
    
    func calculatedWeight(maxWeight: Double) -> Double? {
        if let weight = weight {
            return weight
        } else if let percentage = percentage {
            return maxWeight * Double(percentage) / 100.0
        }
        return nil
    }
}
