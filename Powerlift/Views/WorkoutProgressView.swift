import SwiftUI
import Charts

struct WorkoutProgressView: View {
    @ObservedObject var dataManager: DataManager
    @State private var selectedExercise: ExerciseType = .squat
    @State private var selectedTimeRange: TimeRange = .threeMonths
    @State private var animateCharts = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    ProgressHeader()
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .opacity(animateCharts ? 1 : 0)
                        .offset(y: animateCharts ? 0 : -20)
                    
                    // 🏆 Milestone Badges
                    MilestoneBadgesSection(dataManager: dataManager)
                        .padding(.horizontal, 20)
                        .opacity(animateCharts ? 1 : 0)
                        .offset(y: animateCharts ? 0 : -20)
                    
                    // Exercise Selector with Custom Icons
                    ExerciseSelector(selectedExercise: $selectedExercise)
                        .padding(.horizontal, 20)
                        .opacity(animateCharts ? 1 : 0)
                        .offset(y: animateCharts ? 0 : -20)
                    
                    // 📈 Max Weight Chart
                    MaxWeightChart(
                        dataManager: dataManager,
                        exercise: selectedExercise,
                        timeRange: selectedTimeRange
                    )
                    .padding(.horizontal, 20)
                    .opacity(animateCharts ? 1 : 0)
                    .offset(y: animateCharts ? 0 : -20)
                    
                    // Time Range Selector
                    TimeRangeSelector(selectedTimeRange: $selectedTimeRange)
                        .padding(.horizontal, 20)
                        .opacity(animateCharts ? 1 : 0)
                        .offset(y: animateCharts ? 0 : -20)
                    
                    // 📊 Volume Chart
                    VolumeProgressChart(
                        dataManager: dataManager,
                        timeRange: selectedTimeRange
                    )
                    .padding(.horizontal, 20)
                    .opacity(animateCharts ? 1 : 0)
                    .offset(y: animateCharts ? 0 : -20)
                    
                    // 🔥 Workout Heatmap
                    WorkoutHeatmapSection(dataManager: dataManager)
                        .padding(.horizontal, 20)
                        .opacity(animateCharts ? 1 : 0)
                        .offset(y: animateCharts ? 0 : -20)
                    
                    // PRs Summary with Custom Icons
                    PRsSummarySection(dataManager: dataManager)
                        .padding(.horizontal, 20)
                        .opacity(animateCharts ? 1 : 0)
                        .offset(y: animateCharts ? 0 : -20)
                    
                    Spacer(minLength: 40)
                }
                .padding(.vertical, 10)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animateCharts = true
            }
        }
    }
}

// MARK: - 📋 Progress Header
struct ProgressHeader: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Progress")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Traccia i tuoi progressi")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 32))
                .foregroundColor(AppColors.primary)
        }
    }
}

// MARK: - 🏆 Milestone Badges
struct MilestoneBadgesSection: View {
    @ObservedObject var dataManager: DataManager
    
    var milestones: [(String, String, Bool, Color)] {
        [
            ("💯", "100kg Squat", dataManager.userProfile.squatMax >= 100, .blue),
            ("💪", "100kg Bench", dataManager.userProfile.benchMax >= 100, .orange),
            ("🔥", "200kg Deadlift", dataManager.userProfile.deadliftMax >= 200, .red),
            ("🏋️", "150kg Squat", dataManager.userProfile.squatMax >= 150, .blue),
            ("⚡", "500kg Total", (dataManager.userProfile.squatMax + dataManager.userProfile.benchMax + dataManager.userProfile.deadliftMax) >= 500, .purple)
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🏆 Traguardi")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(milestones.indices, id: \.self) { index in
                        MilestoneBadge(
                            emoji: milestones[index].0,
                            title: milestones[index].1,
                            achieved: milestones[index].2,
                            color: milestones[index].3
                        )
                    }
                }
            }
        }
    }
}

struct MilestoneBadge: View {
    let emoji: String
    let title: String
    let achieved: Bool
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        achieved ? 
                        LinearGradient(
                            colors: [color.opacity(0.3), color.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Text(emoji)
                    .font(.system(size: 30))
                    .grayscale(achieved ? 0 : 1)
                    .opacity(achieved ? 1 : 0.4)
                
                if achieved {
                    Circle()
                        .stroke(color, lineWidth: 2)
                        .frame(width: 60, height: 60)
                }
            }
            
            Text(title)
                .font(.system(size: 10, weight: achieved ? .semibold : .regular))
                .foregroundColor(achieved ? AppColors.textPrimary : AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .frame(width: 80)
        }
    }
}

// MARK: - 🎯 Exercise Selector (Custom Icons)
struct ExerciseSelector: View {
    @Binding var selectedExercise: ExerciseType
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach([ExerciseType.squat, .bench, .deadlift], id: \.self) { exercise in
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        selectedExercise = exercise
                    }
                }) {
                    HStack(spacing: 8) {
                        // Custom Icons invece di emoji
                        exerciseIcon(exercise)
                            .frame(width: 20, height: 20)
                        
                        Text(exercise.displayName)
                            .font(.system(size: 14, weight: selectedExercise == exercise ? .semibold : .regular))
                    }
                    .foregroundColor(selectedExercise == exercise ? .white : AppColors.textSecondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(selectedExercise == exercise ? exerciseColor(exercise) : AppColors.cardBackground)
                    )
                }
            }
        }
    }
    
    @ViewBuilder
    private func exerciseIcon(_ exercise: ExerciseType) -> some View {
        switch exercise {
        case .squat:
            SquatIcon(color: selectedExercise == exercise ? .white : AppColors.primary, size: 16)
        case .bench:
            BenchPressIcon(color: selectedExercise == exercise ? .white : AppColors.accent, size: 16)
        case .deadlift:
            DeadliftIcon(color: selectedExercise == exercise ? .white : AppColors.success, size: 16)
        }
    }
    
    private func exerciseColor(_ exercise: ExerciseType) -> Color {
        switch exercise {
        case .squat: return AppColors.primary
        case .bench: return AppColors.accent
        case .deadlift: return AppColors.success
        }
    }
}

// MARK: - 📈 Max Weight Chart
struct MaxWeightChart: View {
    @ObservedObject var dataManager: DataManager
    let exercise: ExerciseType
    let timeRange: TimeRange
    
    var chartData: [(Date, Double)] {
        dataManager.getMaxWeightChartData(for: exercise, days: timeRange.days)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Peso Massimo - \(exercise.displayName)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                if let last = chartData.last {
                    Text(String(format: "%.1f kg", last.1))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(exerciseColor(exercise))
                }
            }
            
            if !chartData.isEmpty {
                Chart {
                    ForEach(chartData.indices, id: \.self) { index in
                        LineMark(
                            x: .value("Data", chartData[index].0),
                            y: .value("Peso", chartData[index].1)
                        )
                        .foregroundStyle(exerciseColor(exercise))
                        .interpolationMethod(.catmullRom)
                        
                        AreaMark(
                            x: .value("Data", chartData[index].0),
                            y: .value("Peso", chartData[index].1)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [exerciseColor(exercise).opacity(0.3), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)
                        
                        PointMark(
                            x: .value("Data", chartData[index].0),
                            y: .value("Peso", chartData[index].1)
                        )
                        .foregroundStyle(exerciseColor(exercise))
                        .symbolSize(60)
                    }
                }
                .frame(height: 220)
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(AppColors.textSecondary.opacity(0.2))
                        AxisValueLabel()
                            .foregroundStyle(AppColors.textSecondary)
                            .font(.system(size: 11))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(AppColors.textSecondary.opacity(0.2))
                        AxisValueLabel {
                            if let weight = value.as(Double.self) {
                                Text("\(Int(weight))")
                                    .foregroundStyle(AppColors.textSecondary)
                                    .font(.system(size: 11))
                            }
                        }
                    }
                }
            } else {
                EmptyChartView(message: "Nessun dato per \(exercise.displayName)")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.cardBackground)
        )
    }
    
    private func exerciseColor(_ exercise: ExerciseType) -> Color {
        switch exercise {
        case .squat: return AppColors.primary
        case .bench: return AppColors.accent
        case .deadlift: return AppColors.success
        }
    }
}

// MARK: - ⏱️ Time Range Selector
struct TimeRangeSelector: View {
    @Binding var selectedTimeRange: TimeRange
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach([TimeRange.oneMonth, .threeMonths, .sixMonths, .all], id: \.self) { range in
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        selectedTimeRange = range
                    }
                }) {
                    Text(range.displayName)
                        .font(.system(size: 12, weight: selectedTimeRange == range ? .semibold : .regular))
                        .foregroundColor(selectedTimeRange == range ? .white : AppColors.textSecondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedTimeRange == range ? AppColors.primary : AppColors.cardBackground)
                        )
                }
            }
        }
    }
}

enum TimeRange {
    case oneMonth, threeMonths, sixMonths, all
    
    var displayName: String {
        switch self {
        case .oneMonth: return "1M"
        case .threeMonths: return "3M"
        case .sixMonths: return "6M"
        case .all: return "Tutto"
        }
    }
    
    var days: Int {
        switch self {
        case .oneMonth: return 30
        case .threeMonths: return 90
        case .sixMonths: return 180
        case .all: return 3650
        }
    }
}

// MARK: - 📊 Volume Progress Chart
struct VolumeProgressChart: View {
    @ObservedObject var dataManager: DataManager
    let timeRange: TimeRange
    
    var chartData: [(Date, Double)] {
        dataManager.getVolumeChartData(days: timeRange.days)
    }
    
    var totalVolume: Double {
        chartData.reduce(0) { $0 + $1.1 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Volume Totale")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Text(String(format: "%.0f kg", totalVolume))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.accent)
            }
            
            if !chartData.isEmpty {
                Chart {
                    ForEach(chartData.indices, id: \.self) { index in
                        BarMark(
                            x: .value("Data", chartData[index].0),
                            y: .value("Volume", chartData[index].1)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColors.accent, AppColors.accent.opacity(0.6)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(6)
                    }
                }
                .frame(height: 180)
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(AppColors.textSecondary.opacity(0.2))
                        AxisValueLabel()
                            .foregroundStyle(AppColors.textSecondary)
                            .font(.system(size: 11))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [5, 5]))
                            .foregroundStyle(AppColors.textSecondary.opacity(0.2))
                        AxisValueLabel {
                            if let vol = value.as(Double.self) {
                                Text("\(Int(vol))")
                                    .foregroundStyle(AppColors.textSecondary)
                                    .font(.system(size: 11))
                            }
                        }
                    }
                }
            } else {
                EmptyChartView(message: "Inizia ad allenarti per vedere i dati")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.cardBackground)
        )
    }
}

// MARK: - 🔥 Workout Heatmap
struct WorkoutHeatmapSection: View {
    @ObservedObject var dataManager: DataManager
    
    var workoutDays: Set<Date> {
        let calendar = Calendar.current
        var days = Set<Date>()
        for workout in dataManager.workouts {
            let day = calendar.startOfDay(for: workout.date)
            days.insert(day)
        }
        return days
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🔥 Frequenza Allenamenti")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(0..<84, id: \.self) { dayOffset in
                        let date = Calendar.current.date(byAdding: .day, value: -dayOffset, to: Date())!
                        let hasWorkout = workoutDays.contains(Calendar.current.startOfDay(for: date))
                        
                        Rectangle()
                            .fill(hasWorkout ? AppColors.success : AppColors.textSecondary.opacity(0.1))
                            .frame(width: 12, height: 12)
                            .cornerRadius(3)
                    }
                }
            }
            
            HStack(spacing: 8) {
                Circle()
                    .fill(AppColors.textSecondary.opacity(0.1))
                    .frame(width: 8, height: 8)
                Text("Nessun workout")
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textSecondary)
                
                Spacer()
                
                Circle()
                    .fill(AppColors.success)
                    .frame(width: 8, height: 8)
                Text("Completato")
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.cardBackground)
        )
    }
}

// MARK: - 💪 PRs Summary (Custom Icons)
struct PRsSummarySection: View {
    @ObservedObject var dataManager: DataManager
    
    var total: Double {
        dataManager.userProfile.squatMax + dataManager.userProfile.benchMax + dataManager.userProfile.deadliftMax
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Personal Records")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            HStack(spacing: 12) {
                PRCardCustom(
                    title: "Squat",
                    weight: dataManager.userProfile.squatMax,
                    icon: AnyView(SquatIcon(color: AppColors.primary, size: 28)),
                    color: AppColors.primary
                )
                
                PRCardCustom(
                    title: "Panca",
                    weight: dataManager.userProfile.benchMax,
                    icon: AnyView(BenchPressIcon(color: AppColors.accent, size: 28)),
                    color: AppColors.accent
                )
            }
            
            HStack(spacing: 12) {
                PRCardCustom(
                    title: "Stacco",
                    weight: dataManager.userProfile.deadliftMax,
                    icon: AnyView(DeadliftIcon(color: AppColors.success, size: 28)),
                    color: AppColors.success
                )
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("💎")
                        .font(.system(size: 32))
                    
                    Text(String(format: "%.1f kg", total))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Totale")
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color.purple.opacity(0.2), Color.blue.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [Color.purple.opacity(0.4), Color.blue.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
            }
        }
    }
}

// MARK: - PR Card (Custom Icon)
struct PRCardCustom: View {
    let title: String
    let weight: Double
    let icon: AnyView
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            icon
                .frame(width: 32, height: 32)
            
            Text(String(format: "%.1f kg", weight))
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            LinearGradient(
                colors: [color.opacity(0.2), color.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Empty Chart View
struct EmptyChartView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 40))
                .foregroundColor(AppColors.textSecondary.opacity(0.5))
            
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(height: 180)
        .frame(maxWidth: .infinity)
    }
}
