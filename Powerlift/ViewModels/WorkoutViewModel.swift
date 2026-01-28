import Foundation
import SwiftUI
import Combine

class WorkoutViewModel: ObservableObject {
    @Published var selectedExercise: ExerciseType = .squat
    @Published var workingWeight: Double = 100
    @Published var targetReps: Int = 5
    @Published var warmupSets: [WarmupSet] = []
    @Published var workingSets: [WorkoutSet] = []
    @Published var currentRPE: Double = 8.0
    @Published var topSetSuccess: Bool = false
    
    let dataManager: DataManager
    
    init(dataManager: DataManager) {
        self.dataManager = dataManager
    }
    
    // MARK: - Generate Warmup Sets
    func generateWarmupSets(for exercise: ExerciseType, workingWeight: Double) -> [WarmupSet] {
        var sets: [WarmupSet] = []
        
        sets.append(WarmupSet(weight: 20, reps: 10, percentage: 0))
        
        let weight50 = workingWeight * 0.5
        sets.append(WarmupSet(weight: weight50, reps: 5, percentage: 50))
        
        let weight70 = workingWeight * 0.7
        sets.append(WarmupSet(weight: weight70, reps: 3, percentage: 70))
        
        let weight85 = workingWeight * 0.85
        sets.append(WarmupSet(weight: weight85, reps: 2, percentage: 85))
        
        if workingWeight > 80 {
            let weight95 = workingWeight * 0.95
            sets.append(WarmupSet(weight: weight95, reps: 1, percentage: 95))
        }
        
        return sets
    }
    
    // MARK: - Change Exercise
    func changeExercise(to exercise: ExerciseType) {
        selectedExercise = exercise
        
        // Load last working weight for this exercise
        if let lastSet = dataManager.getLastTopSet(for: exercise) {
            workingWeight = lastSet.weight
        }
    }
    
    // MARK: - Add Working Set
    func addWorkingSet(weight: Double, reps: Int, rpe: Double? = nil, isTopSet: Bool = false) {
        let setNumber = workingSets.count + 1
        let set = WorkoutSet(
            setNumber: setNumber,
            weight: weight,
            reps: reps,
            rpe: rpe
        )
        workingSets.append(set)
    }
    
    // MARK: - Target Top Set Weight
    func targetTopSetWeight() -> Double {
        if let lastTopSet = dataManager.getLastTopSet(for: selectedExercise) {
            return lastTopSet.weight + 2.5
        }
        return workingWeight
    }
    
    // MARK: - Calculate Next Weight
    func calculateNextWeight(currentWeight: Double, reps: Int, rpe: Double) -> Double {
        return ProgressionAlgorithm.calculateNextWeight(
            currentWeight: currentWeight,
            reps: reps,
            rpe: rpe,
            athleteLevel: .intermediate,
            exerciseType: selectedExercise
        )
    }
    
    // MARK: - Get Last Top Set
    func getLastTopSet() -> WorkoutSet? {
        return dataManager.getLastTopSet(for: selectedExercise)
    }
    
    // MARK: - Get Progress Text
    func getProgressText() -> String {
        guard let lastTopSet = getLastTopSet() else {
            return "Primo Top Set!"
        }
        
        let targetWeight = targetTopSetWeight()
        let increase = targetWeight - lastTopSet.weight
        
        return String(format: "Ultimo: %.1f kg → Target: %.1f kg (+%.1f kg)",
                     lastTopSet.weight, targetWeight, increase)
    }
    
    // MARK: - Save Workout
    func saveWorkout(name: String) {
        let workout = Workout(
            name: name,
            date: Date(),
            exerciseType: selectedExercise.displayName,
            sets: workingSets,
            notes: nil
        )
        dataManager.addWorkout(workout)
        workingSets.removeAll()
    }
}

// MARK: - Warmup Set Model
struct WarmupSet: Identifiable {
    let id = UUID()
    let weight: Double
    let reps: Int
    let percentage: Int
    var completed: Bool = false
}
