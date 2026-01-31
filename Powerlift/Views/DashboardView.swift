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
                // ⬛ BACKGROUND PULITO
                AppColors.background
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // 🍒 CHERRY THEME HEADER
                        VStack(spacing: 16) {
                            DashboardHeader(dataManager: dataManager)
                                .padding(.horizontal, 20)
                                .padding(.top, 10)
                            
                            // 🍒 Cherry accent bar
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [AppColors.cherry, AppColors.cherry.opacity(0.5)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(height: 4)
                                .padding(.horizontal, 20)
                        }
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
                        
                        // Recent PRs with Custom Icons
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
            .preferredColorScheme(.dark)
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
            withAnimation(.easeOut(duration: 0.6)) {
                animateCards = true
            }
            
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
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.cherry.opacity(0.4), AppColors.cherry.opacity(0.2)],
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
                        .foregroundColor(AppColors.cherry)
                    
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
                .fill(AppColors.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [AppColors.cherry.opacity(0.5), AppColors.cherry.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
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
                            .foregroundColor(AppColors.cherry)
                        
                        Text("kg")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                Spacer()
            }
            
            if !data.isEmpty {
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(data.sorted(by: { $0.0 < $1.0 }), id: \.0) { day, volume in
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            AppColors.cherry,
                                            AppColors.cherry.opacity(0.6)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 30, height: max(barHeight(volume: volume), 4))
                            
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

// MARK: - 🍒 Dashboard Header
struct DashboardHeader: View {
    @ObservedObject var dataManager: DataManager
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text("Dashboard")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Circle()
                        .fill(AppColors.cherry)
                        .frame(width: 8, height: 8)
                }
                
                Text(greetingMessage())
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [AppColors.cherry, AppColors.cherry.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 56, height: 56)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.cherry, AppColors.cherry.opacity(0.8)],
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
            }
            .shadow(color: AppColors.cherry.opacity(0.4), radius: 10, x: 0, y: 5)
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
                    color: AppColors.cherry
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
                    color: AppColors.cherry.opacity(0.8)
                )
            }
        }
    }
}

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
                    .foregroundColor(color)
                
                Text(unit)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.cardBackground)
        )
    }
}

// MARK: - Recent PRs with CUSTOM ICONS 🏋️
struct DashboardRecentPRs: View {
    @ObservedObject var dataManager: DataManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Personal Records")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            HStack(spacing: 12) {
                // SQUAT - Custom Icon
                DashboardPRCardCustom(
                    exercise: "Squat",
                    iconView: AnyView(SquatIcon(color: AppColors.cherry, size: 32)),
                    weight: dataManager.userProfile.squatMax,
                    gradient: [AppColors.cherry, AppColors.cherry.opacity(0.7)]
                )
                
                // BENCH PRESS - Custom Icon
                DashboardPRCardCustom(
                    exercise: "Bench",
                    iconView: AnyView(BenchPressIcon(color: AppColors.accent, size: 32)),
                    weight: dataManager.userProfile.benchMax,
                    gradient: [AppColors.accent, AppColors.accent.opacity(0.7)]
                )
                
                // DEADLIFT - Custom Icon
                DashboardPRCardCustom(
                    exercise: "Deadlift",
                    iconView: AnyView(DeadliftIcon(color: AppColors.success, size: 32)),
                    weight: dataManager.userProfile.deadliftMax,
                    gradient: [AppColors.success, AppColors.success.opacity(0.7)]
                )
            }
        }
    }
}

struct DashboardPRCardCustom: View {
    let exercise: String
    let iconView: AnyView
    let weight: Double
    let gradient: [Color]
    
    var body: some View {
        VStack(spacing: 12) {
            // Icona Custom
            iconView
                .frame(width: 40, height: 40)
            
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
                .fill(AppColors.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: gradient.map { $0.opacity(0.4) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
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
                            .foregroundColor(AppColors.cherry)
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

struct DashboardWorkoutRow: View {
    let workout: Workout
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(AppColors.cherry.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 22))
                        .foregroundColor(AppColors.cherry)
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
                    .foregroundColor(AppColors.cherry)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
