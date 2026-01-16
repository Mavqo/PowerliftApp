import SwiftUI

struct TodayWorkoutCard: View {
    let workout: WorkoutPlan?
    let dataManager: DataManager
    let onStart: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("🏋️ Allenamento di Oggi")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(formatDate(Date()))
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
            }
            
            if let workout = workout {
                // Workout programmato
                VStack(alignment: .leading, spacing: 16) {
                    // Exercise badge
                    HStack(spacing: 12) {
                        Text(workout.exerciseType.emoji)
                            .font(.system(size: 40))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(workout.exerciseType.displayName)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text("\(workout.sets.count) serie programmate")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        Spacer()
                    }
                    
                    // Set summary
                    VStack(spacing: 8) {
                        ForEach(workout.sets.prefix(3)) { set in
                            HStack {
                                Text("Serie \(set.setNumber)")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.textSecondary)
                                
                                Spacer()
                                
                                if let percentage = set.percentage {
                                    let weight = calculateWeight(percentage: percentage, exercise: workout.exerciseType)
                                    Text("\(String(format: "%.1f", weight)) kg")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(AppColors.textPrimary)
                                }
                                
                                Text("× \(set.reps)")
                                    .font(.system(size: 16))
                                    .foregroundColor(AppColors.textSecondary)
                                
                                if let percentage = set.percentage {
                                    Text("(\(percentage)%)")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppColors.textTertiary)
                                }
                            }
                        }
                        
                        if workout.sets.count > 3 {
                            Text("+ altre \(workout.sets.count - 3) serie")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.textTertiary)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppColors.backgroundElevated)
                    )
                    
                    // Notes
                    if let notes = workout.notes {
                        HStack(spacing: 8) {
                            Image(systemName: "note.text")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.accent)
                            
                            Text(notes)
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textSecondary)
                                .lineLimit(2)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(AppColors.accent.opacity(0.1))
                        )
                    }
                    
                    // Start button
                    Button(action: onStart) {
                        HStack {
                            Text("INIZIA ALLENAMENTO")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(AppColors.primary)  // 🍒 Cherry!
                        .cornerRadius(16)
                    }
                }
            } else {
                // Nessun allenamento
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 50))
                        .foregroundColor(AppColors.textSecondary.opacity(0.5))
                    
                    Text("Nessun allenamento programmato")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Vai su Workout per creare o importare")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.cardBackground)
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: date).capitalized
    }
    
    private func calculateWeight(percentage: Int, exercise: ExerciseType) -> Double {
        let maxWeight: Double
        
        switch exercise {
        case .squat:
            maxWeight = dataManager.userProfile.squatMax
        case .bench:
            maxWeight = dataManager.userProfile.benchMax
        case .deadlift:
            maxWeight = dataManager.userProfile.deadliftMax
        }
        
        return maxWeight * Double(percentage) / 100.0
    }
}
