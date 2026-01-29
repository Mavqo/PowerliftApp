import SwiftUI

struct WorkoutProgressView: View {
    @ObservedObject var dataManager: DataManager
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    Text("Progress")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    
                    // PRs Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Personal Records")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                        
                        HStack(spacing: 12) {
                            PRCard(
                                title: "Squat",
                                weight: dataManager.userProfile.squatMax,
                                emoji: "🏋️",
                                color: AppColors.primary
                            )
                            
                            PRCard(
                                title: "Panca",
                                weight: dataManager.userProfile.benchMax,
                                emoji: "💪",
                                color: AppColors.accent
                            )
                        }
                        
                        PRCard(
                            title: "Stacco",
                            weight: dataManager.userProfile.deadliftMax,
                            emoji: "🔥",
                            color: AppColors.success
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Stats
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Statistiche")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                        
                        HStack(spacing: 12) {
                            StatCard(
                                title: "Allenamenti",
                                value: "\(dataManager.getTotalWorkouts())",
                                icon: "figure.strengthtraining.traditional",
                                color: AppColors.primary
                            )
                            
                            StatCard(
                                title: "Volume Totale",
                                value: String(format: "%.0f kg", dataManager.userProfile.totalLifted),
                                icon: "scalemass",
                                color: AppColors.accent
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Coming Soon
                    VStack(spacing: 12) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 48))
                            .foregroundColor(AppColors.textSecondary.opacity(0.5))
                        
                        Text("Grafici in arrivo")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text("Presto vedrai qui i tuoi progressi nel tempo")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textSecondary.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 40)
                    
                    Spacer(minLength: 40)
                }
                .padding(.vertical, 10)
            }
        }
    }
}

// MARK: - PR Card
struct PRCard: View {
    let title: String
    let weight: Double
    let emoji: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(emoji)
                .font(.system(size: 32))
            
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

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
        )
    }
}
