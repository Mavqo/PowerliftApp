import SwiftUI
import Combine

struct DashboardView: View {
    @ObservedObject var dataManager: DataManager
    @StateObject private var viewModel: WorkoutViewModel
    @State private var showingWorkoutSheet = false
    @State private var showingWorkoutExecution = false
    @State private var selectedExercise: ExerciseType = .squat
    @State private var todayWorkout: WorkoutPlan?
    
    init(dataManager: DataManager) {
        self.dataManager = dataManager
        _viewModel = StateObject(wrappedValue: WorkoutViewModel(dataManager: dataManager))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header
                        DashboardHeader(dataManager: dataManager)
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                        
                        // 🆕 TODAY'S WORKOUT CARD
                        TodayWorkoutCard(
                            workout: dataManager.getTodayWorkout(),
                            dataManager: dataManager,
                            onStart: {
                                todayWorkout = dataManager.getTodayWorkout()
                                showingWorkoutExecution = true
                            }
                        )
                        .padding(.horizontal, 20)
                        
                        // Quick Stats
                        DashboardQuickStats(dataManager: dataManager)
                            .padding(.horizontal, 20)
                        
                        // Recent PRs Section
                        DashboardRecentPRs(dataManager: dataManager)
                            .padding(.horizontal, 20)
                        
                        // Recent Workouts
                        DashboardRecentWorkouts(dataManager: dataManager)
                            .padding(.horizontal, 20)
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.vertical, 10)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingWorkoutExecution) {
                if let workout = todayWorkout {
                    WorkoutExecutionView(
                        workout: workout,
                        dataManager: dataManager
                    )
                }
            }
        }
        .onAppear {
            // Auto-sync se connesso a Google Sheets
            Task {
                await dataManager.autoSync()
            }
        }
    }
}

// MARK: - Dashboard Header
struct DashboardHeader: View {
    @ObservedObject var dataManager: DataManager
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Dashboard")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(greetingMessage())
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            Circle()
                .fill(AppColors.primary.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(String(dataManager.userProfile.name.prefix(1)).uppercased())
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(AppColors.primary)
                )
        }
    }
    
    private func greetingMessage() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 0..<12:
            return "Buongiorno! 🌅"
        case 12..<18:
            return "Buon pomeriggio! ☀️"
        default:
            return "Buonasera! 🌙"
        }
    }
}

// MARK: - Quick Stats
struct DashboardQuickStats: View {
    @ObservedObject var dataManager: DataManager
    
    var workoutsThisMonth: Int {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        return dataManager.workouts.filter { $0.date >= startOfMonth }.count
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                DashboardStatCard(
                    title: "Total Volume",
                    value: String(format: "%.0f", dataManager.userProfile.totalLifted),
                    unit: "kg",
                    color: AppColors.primary
                )
                
                DashboardStatCard(
                    title: "Questo Mese",
                    value: String(format: "%.0f", dataManager.getMonthlyVolume()),
                    unit: "kg",
                    color: AppColors.secondary
                )
            }
            
            HStack(spacing: 12) {
                DashboardStatCard(
                    title: "Allenamenti",
                    value: "\(workoutsThisMonth)",
                    unit: "mese",
                    color: AppColors.accent
                )
                
                DashboardStatCard(
                    title: "Questa Sett.",
                    value: String(format: "%.0f", dataManager.getWeeklyVolume()),
                    unit: "kg",
                    color: AppColors.statVelocity
                )
            }
        }
    }
}

// MARK: - Stat Card
struct DashboardStatCard: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(AppColors.textSecondary)
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(unit)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.15))
        )
    }
}

// MARK: - Recent PRs
struct DashboardRecentPRs: View {
    @ObservedObject var dataManager: DataManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Personal Records")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            HStack(spacing: 12) {
                DashboardPRCard(
                    exercise: "Squat",
                    weight: dataManager.userProfile.squatMax,
                    color: AppColors.primary
                )
                
                DashboardPRCard(
                    exercise: "Bench",
                    weight: dataManager.userProfile.benchMax,
                    color: AppColors.secondary
                )
                
                DashboardPRCard(
                    exercise: "Deadlift",
                    weight: dataManager.userProfile.deadliftMax,
                    color: AppColors.accent
                )
            }
        }
    }
}

// MARK: - PR Card
struct DashboardPRCard: View {
    let exercise: String
    let weight: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(exercise)
                .font(.system(size: 12))
                .foregroundColor(AppColors.textSecondary)
            
            Text(String(format: "%.1f", weight))
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            Text("kg")
                .font(.system(size: 10))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.15))
        )
    }
}

// MARK: - Recent Workouts
struct DashboardRecentWorkouts: View {
    @ObservedObject var dataManager: DataManager
    
    var recentWorkouts: [Workout] {
        Array(dataManager.workouts.sorted { $0.date > $1.date }.prefix(5))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Allenamenti Recenti")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                if !recentWorkouts.isEmpty {
                    Button(action: {}) {
                        Text("Vedi tutti")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.primary)
                    }
                }
            }
            
            if recentWorkouts.isEmpty {
                DashboardEmptyState(message: "Nessun allenamento registrato")
            } else {
                VStack(spacing: 12) {
                    ForEach(recentWorkouts) { workout in
                        DashboardWorkoutRow(workout: workout)
                    }
                }
            }
        }
    }
}

// MARK: - Workout Row
struct DashboardWorkoutRow: View {
    let workout: Workout
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(AppColors.primary.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 22))
                        .foregroundColor(AppColors.primary)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                
                HStack(spacing: 8) {
                    Text(workout.exerciseType)
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text("•")
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text("\(workout.sets) sets")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(relativeDate(workout.date))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.cardBackground)
        )
    }
    
    private func relativeDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(date) {
            return "Oggi"
        } else if calendar.isDateInYesterday(date) {
            return "Ieri"
        } else {
            let days = calendar.dateComponents([.day], from: date, to: now).day ?? 0
            if days < 7 {
                return "\(days)g fa"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM"
                return formatter.string(from: date)
            }
        }
    }
}

// MARK: - Empty State
struct DashboardEmptyState: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 50))
                .foregroundColor(AppColors.textSecondary.opacity(0.5))
            
            Text(message)
                .font(.system(size: 16))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - Workout Execution View (Placeholder)
struct WorkoutExecutionView: View {
    let workout: WorkoutPlan
    @ObservedObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Esecuzione Workout")
                        .font(.title.bold())
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(workout.exerciseType.displayName)
                        .font(.title2)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Spacer()
                    
                    Text("Coming Soon")
                        .font(.headline)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text("Qui vedrai:\n• Timer Rest\n• Tracking Serie\n• Note Real-time\n• RPE Input")
                        .font(.body)
                        .foregroundColor(AppColors.textTertiary)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Chiudi") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(AppColors.primary)
                }
            }
        }
    }
}
