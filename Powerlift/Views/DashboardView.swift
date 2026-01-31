import SwiftUI
import Combine
import Charts

struct DashboardView: View {
    @ObservedObject var dataManager: DataManager
    @StateObject private var viewModel: WorkoutViewModel
    @State private var showingWorkoutSheet = false
    @State private var showingWorkoutExecution = false
    @State private var selectedExercise: ExerciseType = .squat
    @State private var todayWorkout: WorkoutPlan?
    @State private var animateCards = false
    
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
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : -20)
                        
                        // 🔥 STREAK COUNTER
                        StreakCounterCard(streak: dataManager.getCurrentStreak())
                            .padding(.horizontal, 20)
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : -20)
                        
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
                        .opacity(animateCards ? 1 : 0)
                        .offset(y: animateCards ? 0 : -20)
                        
                        // 📊 WEEKLY VOLUME CHART
                        WeeklyVolumeSparkline(data: dataManager.getWeeklyVolumeData())
                            .padding(.horizontal, 20)
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : -20)
                        
                        // Quick Stats
                        DashboardQuickStats(dataManager: dataManager)
                            .padding(.horizontal, 20)
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : -20)
                        
                        // Recent PRs Section with Gradients
                        DashboardRecentPRs(dataManager: dataManager)
                            .padding(.horizontal, 20)
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : -20)
                        
                        // Recent Workouts
                        DashboardRecentWorkouts(dataManager: dataManager)
                            .padding(.horizontal, 20)
                            .opacity(animateCards ? 1 : 0)
                            .offset(y: animateCards ? 0 : -20)
                        
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
            // Animazione all'apparizione
            withAnimation(.easeOut(duration: 0.6)) {
                animateCards = true
            }
            
            // Auto-sync se connesso a Google Sheets
            Task {
                await dataManager.autoSync()
            }
        }
    }
}

// MARK: - 🔥 Streak Counter Card
struct StreakCounterCard: View {
    let streak: Int
    @State private var animateFlame = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Flame Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.3), Color.red.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Text("🔥")
                    .font(.system(size: 35))
                    .scaleEffect(animateFlame ? 1.1 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                        value: animateFlame
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Current Streak")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(streak)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(streak == 1 ? "giorno" : "giorni")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Text(streakMessage)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.accent)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color.orange.opacity(0.15), Color.red.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [Color.orange.opacity(0.5), Color.red.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .onAppear {
            animateFlame = true
        }
    }
    
    private var streakMessage: String {
        if streak == 0 {
            return "Inizia oggi! 💪"
        } else if streak < 7 {
            return "Continua così!"
        } else if streak < 30 {
            return "Ottimo lavoro! 🎯"
        } else {
            return "Sei un campione! 🏆"
        }
    }
}

// MARK: - 📊 Weekly Volume Sparkline
struct WeeklyVolumeSparkline: View {
    let data: [(Int, Double)]
    
    private let dayNames = ["L", "M", "M", "G", "V", "S", "D"]
    
    var totalWeekVolume: Double {
        data.reduce(0) { $0 + $1.1 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Volume Settimanale")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(String(format: "%.0f", totalWeekVolume))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppColors.primary)
                        
                        Text("kg")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                Spacer()
            }
            
            // Mini Bar Chart
            if !data.isEmpty {
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(data.sorted(by: { $0.0 < $1.0 }), id: \.0) { day, volume in
                        VStack(spacing: 4) {
                            // Bar
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            AppColors.primary,
                                            AppColors.primary.opacity(0.6)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 30, height: max(barHeight(volume: volume), 4))
                            
                            // Day Label
                            Text(dayNames[day])
                                .font(.system(size: 10))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
                .frame(height: 80)
            } else {
                Text("Nessun dato questa settimana")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.cardBackground)
        )
    }
    
    private func barHeight(volume: Double) -> CGFloat {
        let maxVolume = data.map { $0.1 }.max() ?? 1
        let ratio = maxVolume > 0 ? volume / maxVolume : 0
        return CGFloat(ratio) * 70
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
                .fill(
                    LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 50, height: 50)
                .overlay(
                    Text(String(dataManager.userProfile.name.prefix(1)).uppercased())
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                )
                .shadow(color: AppColors.primary.opacity(0.3), radius: 8, x: 0, y: 4)
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

// MARK: - Recent PRs with Gradients
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
                    emoji: "🏋️",
                    weight: dataManager.userProfile.squatMax,
                    gradient: [AppColors.primary, AppColors.primary.opacity(0.7)]
                )
                
                DashboardPRCard(
                    exercise: "Bench",
                    emoji: "💪",
                    weight: dataManager.userProfile.benchMax,
                    gradient: [AppColors.accent, AppColors.accent.opacity(0.7)]
                )
                
                DashboardPRCard(
                    exercise: "Deadlift",
                    emoji: "🔥",
                    weight: dataManager.userProfile.deadliftMax,
                    gradient: [AppColors.success, AppColors.success.opacity(0.7)]
                )
            }
        }
    }
}

// MARK: - PR Card with Gradient
struct DashboardPRCard: View {
    let exercise: String
    let emoji: String
    let weight: Double
    let gradient: [Color]
    
    var body: some View {
        VStack(spacing: 12) {
            Text(emoji)
                .font(.system(size: 32))
            
            Text(String(format: "%.1f", weight))
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            Text(exercise)
                .font(.system(size: 11))
                .foregroundColor(AppColors.textSecondary)
            
            Text("kg")
                .font(.system(size: 10))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: gradient.map { $0.opacity(0.2) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: gradient.map { $0.opacity(0.4) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
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
