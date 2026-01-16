import SwiftUI
import Combine

struct ExerciseDetailView: View {
    @ObservedObject var dataManager: DataManager
    let exercise: ExerciseType
    @Environment(\.presentationMode) var presentationMode
    
    var recentSets: [WorkoutSet] {
        dataManager.getRecentSets(for: exercise, limit: 20)
    }
    
    var topSets: [WorkoutSet] {
        dataManager.getRecentTopSets(for: exercise, limit: 10)
    }
    
    var lastTopSet: WorkoutSet? {
        dataManager.getLastTopSet(for: exercise)
    }
    
    var estimated1RM: Double {
        lastTopSet?.estimatedOneRepMax ?? 0
    }
    
    var totalVolume: Double {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        return dataManager.getTotalVolume(for: exercise, from: startOfMonth, to: Date())
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    ExerciseDetailHeader(exercise: exercise, estimated1RM: estimated1RM)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    
                    // Stats Cards
                    ExerciseDetailStats(
                        totalVolume: totalVolume,
                        topSetWeight: lastTopSet?.weight ?? 0,
                        totalSets: recentSets.count
                    )
                    .padding(.horizontal, 20)
                    
                    // Top Sets History
                    if !topSets.isEmpty {
                        ExerciseDetailTopSets(topSets: topSets)
                            .padding(.horizontal, 20)
                    }
                    
                    // Recent Sets
                    if !recentSets.isEmpty {
                        ExerciseDetailRecentSets(recentSets: recentSets)
                            .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.vertical, 10)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppColors.primary)
                }
            }
        }
    }
}

// MARK: - Header
struct ExerciseDetailHeader: View {
    let exercise: ExerciseType
    let estimated1RM: Double
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.2))
                    .frame(width: 100, height: 100)
                
                Text(exercise.emoji)
                    .font(.system(size: 50))
            }
            
            Text(exercise.displayName)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            if estimated1RM > 0 {
                VStack(spacing: 4) {
                    Text("Estimated 1RM")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text(String(format: "%.1f kg", estimated1RM))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(AppColors.primary)
                }
            }
        }
    }
}

// MARK: - Stats
struct ExerciseDetailStats: View {
    let totalVolume: Double
    let topSetWeight: Double
    let totalSets: Int
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ExerciseDetailStatCard(
                    title: "Volume Mensile",
                    value: String(format: "%.0f", totalVolume),
                    unit: "kg",
                    color: AppColors.primary
                )
                
                ExerciseDetailStatCard(
                    title: "Top Set",
                    value: String(format: "%.1f", topSetWeight),
                    unit: "kg",
                    color: AppColors.accent
                )
            }
            
            ExerciseDetailStatCard(
                title: "Serie Totali",
                value: "\(totalSets)",
                unit: "sets",
                color: AppColors.success
            )
        }
    }
}

// MARK: - Stat Card
struct ExerciseDetailStatCard: View {
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
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Top Sets
struct ExerciseDetailTopSets: View {
    let topSets: [WorkoutSet]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Top Sets History")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            VStack(spacing: 12) {
                ForEach(topSets) { set in
                    ExerciseDetailSetRow(set: set, isTopSet: true)
                }
            }
        }
    }
}

// MARK: - Recent Sets
struct ExerciseDetailRecentSets: View {
    let recentSets: [WorkoutSet]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Serie Recenti")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            VStack(spacing: 12) {
                ForEach(recentSets) { set in
                    ExerciseDetailSetRow(set: set, isTopSet: false)
                }
            }
        }
    }
}

// MARK: - Set Row
struct ExerciseDetailSetRow: View {
    let set: WorkoutSet
    let isTopSet: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Date
            VStack(alignment: .leading, spacing: 2) {
                Text(formatDate(set.timestamp))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(formatTime(set.timestamp))
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            // Weight x Reps
            HStack(spacing: 8) {
                Text("\(String(format: "%.1f", set.weight)) kg")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("×")
                    .foregroundColor(AppColors.textSecondary)
                
                Text("\(set.reps)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.primary)
            }
            
            // RPE (se disponibile)
            if let rpe = set.rpe {
                Text("RPE \(String(format: "%.1f", rpe))")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(rpeColor(rpe))
                    )
            }
            
            // Top Set Badge
            if isTopSet {
                Image(systemName: "star.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.accent)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.cardBackground)
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private func rpeColor(_ rpe: Double) -> Color {
        switch rpe {
        case 0..<7:
            return AppColors.success
        case 7..<8:
            return AppColors.statVelocity
        case 8..<9:
            return AppColors.warning
        default:
            return AppColors.error
        }
    }
}
