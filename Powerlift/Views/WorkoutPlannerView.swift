import SwiftUI

struct WorkoutPlannerView: View {
    @ObservedObject var dataManager: DataManager
    @State private var showingGoogleSheetsSetup = false
    @State private var showingManualCreator = false
    
    var upcomingWorkouts: [WorkoutPlan] {
        dataManager.getUpcomingWorkouts(days: 14)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Gestione Allenamenti")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text("Importa o crea la tua programmazione")
                                .font(.system(size: 16))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Opzione 1: Google Sheets
                        WorkoutSourceCard(
                            icon: "doc.text.fill",
                            title: "Import da Google Sheets",
                            description: "Sincronizza con il tuo coach",
                            color: AppColors.primary,
                            badge: dataManager.sheetsSync.isConnected ? "Connesso" : nil
                        ) {
                            showingGoogleSheetsSetup = true
                        }
                        .padding(.horizontal, 20)
                        
                        // Opzione 2: Creazione Manuale
                        WorkoutSourceCard(
                            icon: "square.and.pencil",
                            title: "Crea Manuale",
                            description: "Programma il tuo workout",
                            color: AppColors.secondary
                        ) {
                            showingManualCreator = true
                        }
                        .padding(.horizontal, 20)
                        
                        // Prossimi Allenamenti
                        if !upcomingWorkouts.isEmpty {
                            UpcomingWorkoutsSection(workouts: upcomingWorkouts)
                                .padding(.horizontal, 20)
                        }
                        
                        Spacer(minLength: 80)
                    }
                    .padding(.vertical, 10)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingGoogleSheetsSetup) {
                GoogleSheetsSetupView(
                    dataManager: dataManager,
                    sheetsSync: dataManager.sheetsSync
                )
            }
            .sheet(isPresented: $showingManualCreator) {
                ManualWorkoutCreatorView(dataManager: dataManager)
            }
        }
    }
}

// MARK: - Workout Source Card
struct WorkoutSourceCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    var badge: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(color.opacity(0.2))
                            .frame(width: 70, height: 70)
                        
                        Image(systemName: icon)
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(color)
                    }
                    
                    Spacer()
                    
                    if let badge = badge {
                        Text(badge)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AppColors.success)
                            .cornerRadius(12)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(description)
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                HStack {
                    Text("Tocca per continuare")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(color)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(color)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppColors.cardBackground)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Upcoming Workouts Section
struct UpcomingWorkoutsSection: View {
    let workouts: [WorkoutPlan]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Prossimi Allenamenti")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            VStack(spacing: 12) {
                ForEach(workouts.prefix(5)) { workout in
                    UpcomingWorkoutRow(workout: workout)
                }
            }
        }
    }
}

// MARK: - Upcoming Workout Row
struct UpcomingWorkoutRow: View {
    let workout: WorkoutPlan
    
    var body: some View {
        HStack(spacing: 16) {
            // Date indicator
            VStack(spacing: 2) {
                Text(dayString(workout.date))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
                
                Text(dayNumber(workout.date))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(monthString(workout.date))
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }
            .frame(width: 60)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.primary.opacity(0.1))
            )
            
            // Workout info
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.exerciseType.displayName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("\(workout.sets.count) serie programmate")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
                
                if let notes = workout.notes {
                    Text(notes)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textTertiary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.cardBackground)
        )
    }
    
    private func dayString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: date).uppercased()
    }
    
    private func dayNumber(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter.string(from: date)
    }
    
    private func monthString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: date).uppercased()
    }
}
