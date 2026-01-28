import Foundation
import SwiftUI
import Combine

class DataManager: ObservableObject {
    
    @Published var userProfile: UserProfile
    @Published var workouts: [Workout] = []
    @Published var workoutPlans: [WorkoutPlan] = []
    @Published var exercises: [Exercise] = []
    
    let sheetsSync = GoogleSheetsSync()
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "userProfile"),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.userProfile = decoded
        } else {
            self.userProfile = UserProfile(
                name: "Atleta",
                email: "",
                bodyweight: 75.0,
                height: 175.0,
                age: 0,
                athleteLevel: .beginner,
                squatMax: 100.0,
                benchMax: 80.0,
                deadliftMax: 120.0,
                totalLifted: 0.0,
                hasCompletedOnboarding: false
            )
            saveUserProfile()
        }
        
        loadWorkouts()
        loadWorkoutPlans()
        loadExercises()
        sheetsSync.restoreSession()
    }
    
    // MARK: - User Profile
    
    func updateUserProfile(name: String? = nil, bodyweight: Double? = nil, squatMax: Double? = nil, benchMax: Double? = nil, deadliftMax: Double? = nil) {
        if let name = name {
            userProfile.name = name
        }
        if let bodyweight = bodyweight {
            userProfile.bodyweight = bodyweight
        }
        if let squatMax = squatMax {
            userProfile.squatMax = squatMax
        }
        if let benchMax = benchMax {
            userProfile.benchMax = benchMax
        }
        if let deadliftMax = deadliftMax {
            userProfile.deadliftMax = deadliftMax
        }
        saveUserProfile()
    }
    
    func saveProfile(_ profile: UserProfile) {
        userProfile = profile
        saveUserProfile()
    }
    
    func saveUserProfile() {
        if let encoded = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(encoded, forKey: "userProfile")
        }
    }
    
    func completeOnboarding() {
        userProfile.hasCompletedOnboarding = true
        saveUserProfile()
    }
    
    // MARK: - Workouts
    
    func addWorkout(_ workout: Workout) {
        workouts.append(workout)
        let workoutVolume = workout.totalVolume
        userProfile.totalLifted += workoutVolume
        saveWorkouts()
        saveUserProfile()
    }
    
    func deleteWorkout(_ workout: Workout) {
        if let index = workouts.firstIndex(where: { $0.id == workout.id }) {
            let deletedWorkout = workouts.remove(at: index)
            userProfile.totalLifted -= deletedWorkout.totalVolume
            saveWorkouts()
            saveUserProfile()
        }
    }
    
    func updateWorkout(_ workout: Workout) {
        if let index = workouts.firstIndex(where: { $0.id == workout.id }) {
            workouts[index] = workout
            saveWorkouts()
        }
    }
    
    func saveWorkouts() {
        if let encoded = try? JSONEncoder().encode(workouts) {
            UserDefaults.standard.set(encoded, forKey: "workouts")
        }
    }
    
    func loadWorkouts() {
        if let data = UserDefaults.standard.data(forKey: "workouts"),
           let decoded = try? JSONDecoder().decode([Workout].self, from: data) {
            workouts = decoded
        }
    }
    
    // MARK: - Workout Plans
    
    func addWorkoutPlan(_ plan: WorkoutPlan) {
        workoutPlans.append(plan)
        saveWorkoutPlans()
    }
    
    func deleteWorkoutPlan(_ plan: WorkoutPlan) {
        if let index = workoutPlans.firstIndex(where: { $0.id == plan.id }) {
            workoutPlans.remove(at: index)
            saveWorkoutPlans()
        }
    }
    
    func updateWorkoutPlan(_ plan: WorkoutPlan) {
        if let index = workoutPlans.firstIndex(where: { $0.id == plan.id }) {
            workoutPlans[index] = plan
            saveWorkoutPlans()
        }
    }
    
    func completeWorkoutPlan(_ plan: WorkoutPlan) {
        if let index = workoutPlans.firstIndex(where: { $0.id == plan.id }) {
            workoutPlans[index].completed = true
            saveWorkoutPlans()
        }
    }
    
    func getTodayWorkout() -> WorkoutPlan? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return workoutPlans.first { plan in
            calendar.isDate(plan.date, inSameDayAs: today) && !plan.completed
        }
    }
    
    func getUpcomingWorkouts(days: Int = 7) -> [WorkoutPlan] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let futureDate = calendar.date(byAdding: .day, value: days, to: today)!
        
        return workoutPlans.filter { plan in
            plan.date >= today && plan.date <= futureDate && !plan.completed
        }.sorted { $0.date < $1.date }
    }
    
    func saveWorkoutPlans() {
        if let encoded = try? JSONEncoder().encode(workoutPlans) {
            UserDefaults.standard.set(encoded, forKey: "workoutPlans")
        }
    }
    
    func loadWorkoutPlans() {
        if let data = UserDefaults.standard.data(forKey: "workoutPlans"),
           let decoded = try? JSONDecoder().decode([WorkoutPlan].self, from: data) {
            workoutPlans = decoded
        }
    }
    
    // MARK: - Google Sheets Sync
    
    func syncFromGoogleSheets() async {
        let plans = await sheetsSync.syncWorkoutPlans()
        await MainActor.run {
            self.workoutPlans = plans
            self.saveWorkoutPlans()
        }
    }
    
    func autoSync() async {
        if sheetsSync.isConnected {
            await syncFromGoogleSheets()
        }
    }
    
    // MARK: - Exercises
    
    func addExercise(_ exercise: Exercise) {
        exercises.append(exercise)
        saveExercises()
    }
    
    func saveExercises() {
        if let encoded = try? JSONEncoder().encode(exercises) {
            UserDefaults.standard.set(encoded, forKey: "exercises")
        }
    }
    
    func loadExercises() {
        if let data = UserDefaults.standard.data(forKey: "exercises"),
           let decoded = try? JSONDecoder().decode([Exercise].self, from: data) {
            exercises = decoded
        }
    }
    
    // MARK: - Statistics
    
    func getWeeklyVolume() -> Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        
        return workouts
            .filter { $0.date >= startOfWeek }
            .reduce(0.0) { $0 + $1.totalVolume }
    }
    
    func getMonthlyVolume() -> Double {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        
        return workouts
            .filter { $0.date >= startOfMonth }
            .reduce(0.0) { $0 + $1.totalVolume }
    }
    
    func getTotalWorkouts() -> Int {
        return workouts.count
    }
    
    func getWorkoutsThisMonth() -> Int {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        return workouts.filter { $0.date >= startOfMonth }.count
    }
    
    func getWorkoutsThisWeek() -> Int {
        let calendar = Calendar.current
        let now = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        return workouts.filter { $0.date >= startOfWeek }.count
    }
    
    func getAverageRPE() -> Double {
        let allSets = workouts.flatMap { $0.sets }
        let rpeSets = allSets.filter { $0.rpe != nil }
        guard !rpeSets.isEmpty else { return 0 }
        let totalRPE = rpeSets.reduce(0.0) { $0 + ($1.rpe ?? 0) }
        return totalRPE / Double(rpeSets.count)
    }
    
    func getVolumeByExercise(_ exerciseType: ExerciseType) -> Double {
        return workouts
            .filter { $0.exerciseType == exerciseType.rawValue }
            .reduce(0.0) { $0 + $1.totalVolume }
    }
    
    func getRecentWorkouts(limit: Int = 10) -> [Workout] {
        return Array(workouts.sorted { $0.date > $1.date }.prefix(limit))
    }
    
    func getWorkoutsByExercise(_ exerciseType: ExerciseType) -> [Workout] {
        return workouts.filter { $0.exerciseType == exerciseType.rawValue }
    }
    
    
    // MARK: - Top Set Methods

    func getLastTopSet(for exerciseType: ExerciseType) -> WorkoutSet? {
        let exerciseWorkouts = workouts
            .filter { $0.exerciseType == exerciseType.rawValue }
            .sorted { $0.date > $1.date }
        
        guard let lastWorkout = exerciseWorkouts.first else { return nil }
        
        // Trova il set con peso massimo
        return lastWorkout.sets.max(by: { $0.weight < $1.weight })
    }

    func getTopSetForExercise(_ exerciseType: ExerciseType) -> WorkoutSet? {
        let exerciseWorkouts = workouts.filter { $0.exerciseType == exerciseType.rawValue }
        
        var topSet: WorkoutSet?
        var maxWeight: Double = 0
        
        for workout in exerciseWorkouts {
            for set in workout.sets {
                if set.weight > maxWeight {
                    maxWeight = set.weight
                    topSet = set
                }
            }
        }
        
        return topSet
    }

    // MARK: - Personal Records
    
    func updatePR(for exercise: ExerciseType, weight: Double) {
        switch exercise {
        case .squat:
            if weight > userProfile.squatMax {
                userProfile.squatMax = weight
                saveUserProfile()
            }
        case .bench:
            if weight > userProfile.benchMax {
                userProfile.benchMax = weight
                saveUserProfile()
            }
        case .deadlift:
            if weight > userProfile.deadliftMax {
                userProfile.deadliftMax = weight
                saveUserProfile()
            }
        }
    }
    
    func checkForPR(workout: Workout) {
        guard let exerciseType = ExerciseType(rawValue: workout.exerciseType) else { return }
        
        let weights = workout.sets.map { $0.weight }
        guard let maxWeight = weights.max() else { return }
        
        let currentPR: Double
        switch exerciseType {
        case .squat:
            currentPR = userProfile.squatMax
        case .bench:
            currentPR = userProfile.benchMax
        case .deadlift:
            currentPR = userProfile.deadliftMax
        }
        
        if maxWeight > currentPR {
            updatePR(for: exerciseType, weight: maxWeight)
        }
    }
    
    // MARK: - Data Management
    
    func clearAllData() {
        workouts.removeAll()
        workoutPlans.removeAll()
        exercises.removeAll()
        userProfile.totalLifted = 0
        saveWorkouts()
        saveWorkoutPlans()
        saveExercises()
        saveUserProfile()
    }
    
    func exportData() -> String {
        var csvString = "Date,Exercise,Sets,Reps,Weight,RPE,Volume\n"
        
        for workout in workouts.sorted(by: { $0.date < $1.date }) {
            for set in workout.sets {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                let dateString = dateFormatter.string(from: workout.date)
                let volume = set.weight * Double(set.reps)
                let rpeString = set.rpe != nil ? String(format: "%.1f", set.rpe!) : ""
                csvString += "\(dateString),\(workout.exerciseType),\(set.setNumber),\(set.reps),\(set.weight),\(rpeString),\(volume)\n"
            }
        }
        
        return csvString
    }
    
    func getVolumeChartData(days: Int = 30) -> [(Date, Double)] {
        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .day, value: -days, to: now)!
        
        var volumeByDate: [Date: Double] = [:]
        
        for workout in workouts {
            if workout.date >= startDate {
                let dayStart = calendar.startOfDay(for: workout.date)
                volumeByDate[dayStart, default: 0] += workout.totalVolume
            }
        }
        
        return volumeByDate.sorted { $0.key < $1.key }
    }
    
    func getMaxWeightChartData(for exerciseType: ExerciseType, days: Int = 90) -> [(Date, Double)] {
        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .day, value: -days, to: now)!
        
        let filteredWorkouts = workouts
            .filter { $0.exerciseType == exerciseType.rawValue && $0.date >= startDate }
            .sorted { $0.date < $1.date }
        
        var maxWeightByDate: [(Date, Double)] = []
        
        for workout in filteredWorkouts {
            let weights = workout.sets.map { $0.weight }
            if let maxWeight = weights.max() {
                maxWeightByDate.append((workout.date, maxWeight))
            }
        }
        
        return maxWeightByDate
    }
}

struct Exercise: Codable, Identifiable {
    let id: UUID
    let name: String
    let type: String
    let category: String
    
    init(name: String, type: String, category: String) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.category = category
    }
}
