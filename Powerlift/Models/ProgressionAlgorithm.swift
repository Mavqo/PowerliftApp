import Foundation

struct ProgressionAlgorithm {
    
    // MARK: - Calculate Next Weight
    static func calculateNextWeight(
        currentWeight: Double,
        reps: Int,
        rpe: Double,
        athleteLevel: AthleteLevel,
        exerciseType: ExerciseType
    ) -> Double {
        
        let baseIncrement = getBaseIncrement(for: athleteLevel, exercise: exerciseType)
        
        // RPE-based adjustment
        let rpeMultiplier: Double
        switch rpe {
        case 0..<7:
            rpeMultiplier = 1.5
        case 7..<8:
            rpeMultiplier = 1.2
        case 8..<9:
            rpeMultiplier = 1.0
        case 9..<9.5:
            rpeMultiplier = 0.5
        default:
            rpeMultiplier = 0.0
        }
        
        // Reps-based adjustment
        let repsMultiplier: Double
        switch reps {
        case 1...3:
            repsMultiplier = 1.0
        case 4...6:
            repsMultiplier = 1.2
        case 7...10:
            repsMultiplier = 1.5
        default:
            repsMultiplier = 2.0
        }
        
        let increment = baseIncrement * rpeMultiplier * repsMultiplier
        return currentWeight + increment
    }
    
    // MARK: - Base Increment by Level & Exercise
    private static func getBaseIncrement(for level: AthleteLevel, exercise: ExerciseType) -> Double {
        switch level {
        case .beginner:
            return exercise == .bench ? 2.5 : 5.0
        case .intermediate:
            return exercise == .bench ? 1.25 : 2.5
        case .advanced:
            return exercise == .bench ? 0.5 : 1.25
        case .elite:
            return exercise == .bench ? 0.25 : 0.5
        }
    }
    
    // MARK: - Recommended Volume
    static func recommendedVolume(for level: AthleteLevel, exercise: ExerciseType) -> (sets: Int, repsRange: ClosedRange<Int>) {
        switch level {
        case .beginner:
            switch exercise {
            case .squat:
                return (sets: 3, repsRange: 5...8)
            case .bench:
                return (sets: 3, repsRange: 5...8)
            case .deadlift:
                return (sets: 3, repsRange: 3...5)
            }
            
        case .intermediate:
            switch exercise {
            case .squat:
                return (sets: 4, repsRange: 4...6)
            case .bench:
                return (sets: 4, repsRange: 4...6)
            case .deadlift:
                return (sets: 4, repsRange: 3...5)
            }
            
        case .advanced:
            switch exercise {
            case .squat:
                return (sets: 5, repsRange: 3...5)
            case .bench:
                return (sets: 5, repsRange: 3...5)
            case .deadlift:
                return (sets: 5, repsRange: 2...4)
            }
            
        case .elite:
            switch exercise {
            case .squat:
                return (sets: 6, repsRange: 2...4)
            case .bench:
                return (sets: 6, repsRange: 2...4)
            case .deadlift:
                return (sets: 6, repsRange: 1...3)
            }
        }
    }
    
    // MARK: - Frequency Recommendation
    static func recommendedFrequency(for level: AthleteLevel, exercise: ExerciseType) -> Int {
        switch level {
        case .beginner:
            return exercise == .deadlift ? 1 : 2
        case .intermediate:
            return exercise == .deadlift ? 2 : 3
        case .advanced:
            return 3
        case .elite:
            return exercise == .deadlift ? 3 : 4
        }
    }
    
    // MARK: - Calculate Estimated 1RM
    static func calculateEstimated1RM(weight: Double, reps: Int, formula: RMFormula = .epley) -> Double {
        switch formula {
        case .epley:
            return weight * (1 + Double(reps) / 30)
        case .brzycki:
            return weight * (36 / (37 - Double(reps)))
        case .lander:
            return (100 * weight) / (101.3 - 2.67123 * Double(reps))
        }
    }
    
    // MARK: - Calculate Training Max
    static func calculateTrainingMax(oneRepMax: Double) -> Double {
        return oneRepMax * 0.9
    }
    
    // MARK: - Calculate Weight for Target Reps
    static func calculateWeightForReps(oneRepMax: Double, targetReps: Int) -> Double {
        return oneRepMax / (1 + Double(targetReps) / 30)
    }
    
    // MARK: - Deload Recommendation
    static func shouldDeload(recentSets: [WorkoutSet], weeksOfTraining: Int) -> Bool {
        if weeksOfTraining % 4 == 0 {
            return true
        }
        
        guard recentSets.count >= 6 else { return false }
        
        let recentAverage = recentSets.prefix(3).map { $0.estimatedOneRepMax }.reduce(0, +) / 3
        let previousAverage = recentSets.dropFirst(3).prefix(3).map { $0.estimatedOneRepMax }.reduce(0, +) / 3
        
        return recentAverage < previousAverage * 0.95
    }
    
    // MARK: - Deload Weight
    static func deloadWeight(currentWeight: Double) -> Double {
        return currentWeight * 0.7
    }
}

// MARK: - 1RM Formula Enum
enum RMFormula {
    case epley
    case brzycki
    case lander
}

// MARK: - Training Phase
enum TrainingPhase {
    case hypertrophy
    case strength
    case power
    case peaking
    
    var repsRange: ClosedRange<Int> {
        switch self {
        case .hypertrophy:
            return 8...12
        case .strength:
            return 4...6
        case .power:
            return 2...4
        case .peaking:
            return 1...3
        }
    }
    
    var intensityRange: ClosedRange<Double> {
        switch self {
        case .hypertrophy:
            return 65...75
        case .strength:
            return 75...85
        case .power:
            return 85...92
        case .peaking:
            return 90...100
        }
    }
}
