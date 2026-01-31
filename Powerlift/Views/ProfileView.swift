import SwiftUI

struct ProfileView: View {
    @ObservedObject var dataManager: DataManager
    @State private var isEditing = false
    @State private var animateRings = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header con Avatar
                    ProfileHeader(dataManager: dataManager)
                        .padding(.top, 20)
                    
                    // 🏆 Achievement Badges
                    ProfileAchievementsSection(dataManager: dataManager)
                        .padding(.horizontal, 20)
                    
                    // 💪 Progress Rings (Apple Fitness Style)
                    ProgressRingsSection(dataManager: dataManager, animateRings: $animateRings)
                        .padding(.horizontal, 20)
                    
                    // 📊 Wilks Score
                    WilksScoreSection(dataManager: dataManager)
                        .padding(.horizontal, 20)
                    
                    // Stats Cards
                    ProfileStatsSection(dataManager: dataManager)
                        .padding(.horizontal, 20)
                    
                    // Massimali Section
                    ProfileMaxesSection(dataManager: dataManager)
                        .padding(.horizontal, 20)
                    
                    // Informazioni Personali
                    ProfileInfoSection(dataManager: dataManager)
                        .padding(.horizontal, 20)
                    
                    // Edit Button
                    Button(action: {
                        isEditing = true
                    }) {
                        HStack {
                            Image(systemName: "pencil")
                            Text("Modifica Profilo")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [AppColors.primary, AppColors.accent],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: AppColors.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 40)
                }
                .padding(.vertical, 10)
            }
        }
        .sheet(isPresented: $isEditing) {
            EditProfileView(dataManager: dataManager, isPresented: $isEditing)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.2)) {
                animateRings = true
            }
        }
    }
}

// MARK: - 🏆 Achievements Section
struct ProfileAchievementsSection: View {
    @ObservedObject var dataManager: DataManager
    
    var achievements: [(String, String, Bool, Color)] {
        let total = dataManager.userProfile.squatMax + dataManager.userProfile.benchMax + dataManager.userProfile.deadliftMax
        let totalWorkouts = dataManager.getTotalWorkouts()
        
        return [
            ("🥉", "Prima alzata", totalWorkouts >= 1, .orange),
            ("💯", "100 Allenamenti", totalWorkouts >= 100, .blue),
            ("🏋️", "100kg Club", dataManager.userProfile.squatMax >= 100 || dataManager.userProfile.benchMax >= 100 || dataManager.userProfile.deadliftMax >= 100, .purple),
            ("💪", "500kg Total", total >= 500, .red),
            ("👑", "Elite Lifter", dataManager.userProfile.athleteLevel == .elite, .yellow),
            ("🔥", "Streak Master", dataManager.getCurrentStreak() >= 7, .orange)
        ]
    }
    
    var achievedCount: Int {
        achievements.filter { $0.2 }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("🏆 Achievements")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Text("\(achievedCount)/\(achievements.count)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.accent)
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(achievements.indices, id: \.self) { index in
                    AchievementBadge(
                        emoji: achievements[index].0,
                        title: achievements[index].1,
                        achieved: achievements[index].2,
                        color: achievements[index].3
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.cardBackground)
        )
    }
}

struct AchievementBadge: View {
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
                            colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                
                Text(emoji)
                    .font(.system(size: 28))
                    .grayscale(achieved ? 0 : 1)
                    .opacity(achieved ? 1 : 0.3)
                
                if achieved {
                    Circle()
                        .stroke(color, lineWidth: 2)
                        .frame(width: 56, height: 56)
                }
            }
            
            Text(title)
                .font(.system(size: 9, weight: achieved ? .semibold : .regular))
                .foregroundColor(achieved ? AppColors.textPrimary : AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 24)
        }
    }
}

// MARK: - 💪 Progress Rings (Apple Fitness Style)
struct ProgressRingsSection: View {
    @ObservedObject var dataManager: DataManager
    @Binding var animateRings: Bool
    
    var squatProgress: Double {
        min(dataManager.userProfile.squatMax / 200.0, 1.0)
    }
    
    var benchProgress: Double {
        min(dataManager.userProfile.benchMax / 150.0, 1.0)
    }
    
    var deadliftProgress: Double {
        min(dataManager.userProfile.deadliftMax / 250.0, 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("💪 Obiettivi")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            HStack(spacing: 24) {
                // Progress Rings
                ZStack {
                    ProgressRing(progress: animateRings ? squatProgress : 0, color: AppColors.primary, lineWidth: 12)
                        .frame(width: 100, height: 100)
                    
                    ProgressRing(progress: animateRings ? benchProgress : 0, color: AppColors.accent, lineWidth: 12)
                        .frame(width: 75, height: 75)
                    
                    ProgressRing(progress: animateRings ? deadliftProgress : 0, color: AppColors.success, lineWidth: 12)
                        .frame(width: 50, height: 50)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    ProgressRingLegend(
                        color: AppColors.primary,
                        title: "Squat",
                        current: dataManager.userProfile.squatMax,
                        goal: 200
                    )
                    
                    ProgressRingLegend(
                        color: AppColors.accent,
                        title: "Bench",
                        current: dataManager.userProfile.benchMax,
                        goal: 150
                    )
                    
                    ProgressRingLegend(
                        color: AppColors.success,
                        title: "Deadlift",
                        current: dataManager.userProfile.deadliftMax,
                        goal: 250
                    )
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [AppColors.cardBackground, AppColors.cardBackground.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
        }
    }
}

struct ProgressRing: View {
    let progress: Double
    let color: Color
    let lineWidth: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1.0), value: progress)
        }
    }
}

struct ProgressRingLegend: View {
    let color: Color
    let title: String
    let current: Double
    let goal: Double
    
    var percentage: Int {
        Int(min((current / goal) * 100, 100))
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("\(Int(current))/\(Int(goal)) kg (\(percentage)%)")
                    .font(.system(size: 11))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }
}

// MARK: - 📊 Wilks Score
struct WilksScoreSection: View {
    @ObservedObject var dataManager: DataManager
    
    var wilksScore: Double {
        calculateWilks(
            bodyweight: dataManager.userProfile.bodyweight,
            total: dataManager.userProfile.squatMax + dataManager.userProfile.benchMax + dataManager.userProfile.deadliftMax,
            isMale: true
        )
    }
    
    var wilksRating: (String, Color) {
        switch wilksScore {
        case 0..<200: return ("Principiante", .gray)
        case 200..<300: return ("Intermedio", .blue)
        case 300..<400: return ("Avanzato", .purple)
        case 400..<500: return ("Elite", .orange)
        default: return ("World Class", .red)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("📊 Wilks Score")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Coefficiente forza relativa")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(String(format: "%.1f", wilksScore))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(wilksRating.1)
                    
                    Text(wilksRating.0)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(wilksRating.1)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(wilksRating.1.opacity(0.2))
                        )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [wilksRating.1.opacity(0.15), wilksRating.1.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [wilksRating.1.opacity(0.3), wilksRating.1.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

// Wilks Coefficient Calculation
func calculateWilks(bodyweight: Double, total: Double, isMale: Bool) -> Double {
    guard bodyweight > 0, total > 0 else { return 0 }
    
    let coefficients: [Double]
    if isMale {
        coefficients = [-216.0475144, 16.2606339, -0.002388645, -0.00113732, 7.01863E-06, -1.291E-08]
    } else {
        coefficients = [594.31747775582, -27.23842536447, 0.82112226871, -0.00930733913, 4.731582E-05, -9.054E-08]
    }
    
    let bw = bodyweight
    let denominator = coefficients[0] +
                     coefficients[1] * bw +
                     coefficients[2] * pow(bw, 2) +
                     coefficients[3] * pow(bw, 3) +
                     coefficients[4] * pow(bw, 4) +
                     coefficients[5] * pow(bw, 5)
    
    return total * 500 / denominator
}

// MARK: - Header
struct ProfileHeader: View {
    @ObservedObject var dataManager: DataManager
    
    var initials: String {
        let name = dataManager.userProfile.name
        let components = name.split(separator: " ")
        if components.count >= 2 {
            return "\(components[0].prefix(1))\(components[1].prefix(1))".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Avatar with gradient border
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.primary, AppColors.accent, AppColors.success],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 130, height: 130)
                
                Circle()
                    .fill(AppColors.background)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.primary.opacity(0.8), AppColors.accent.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 116, height: 116)
                
                Text(initials)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
            }
            .shadow(color: AppColors.primary.opacity(0.4), radius: 20, x: 0, y: 10)
            
            // Nome
            Text(dataManager.userProfile.name)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            // Livello
            HStack(spacing: 8) {
                Text(dataManager.userProfile.athleteLevel.emoji)
                    .font(.system(size: 14))
                
                Text(dataManager.userProfile.athleteLevel.displayName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.primary.opacity(0.2), AppColors.accent.opacity(0.2)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
        }
    }
}

// MARK: - Stats Section
struct ProfileStatsSection: View {
    @ObservedObject var dataManager: DataManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistiche")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            HStack(spacing: 12) {
                ProfileStatCard(
                    title: "Allenamenti",
                    value: "\(dataManager.getTotalWorkouts())",
                    icon: "figure.strengthtraining.traditional",
                    color: AppColors.primary
                )
                
                ProfileStatCard(
                    title: "Volume Totale",
                    value: String(format: "%.0f kg", dataManager.userProfile.totalLifted),
                    icon: "scalemass",
                    color: AppColors.accent
                )
            }
        }
    }
}

struct ProfileStatCard: View {
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
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.15), color.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
}

// MARK: - Maxes Section
struct ProfileMaxesSection: View {
    @ObservedObject var dataManager: DataManager
    
    var total: Double {
        dataManager.userProfile.squatMax + dataManager.userProfile.benchMax + dataManager.userProfile.deadliftMax
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Massimali")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            VStack(spacing: 12) {
                ProfileMaxRow(
                    exercise: "🏋️ Squat",
                    max: dataManager.userProfile.squatMax,
                    color: AppColors.primary
                )
                
                ProfileMaxRow(
                    exercise: "💪 Panca",
                    max: dataManager.userProfile.benchMax,
                    color: AppColors.accent
                )
                
                ProfileMaxRow(
                    exercise: "🔥 Stacco",
                    max: dataManager.userProfile.deadliftMax,
                    color: AppColors.success
                )
                
                Divider()
                    .background(AppColors.textSecondary.opacity(0.3))
                    .padding(.vertical, 4)
                
                // Totale
                HStack {
                    Text("💎 Totale")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Text(String(format: "%.1f kg", total))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(AppColors.primary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [AppColors.primary.opacity(0.2), AppColors.accent.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.cardBackground)
            )
        }
    }
}

struct ProfileMaxRow: View {
    let exercise: String
    let max: Double
    let color: Color
    
    var body: some View {
        HStack {
            Text(exercise)
                .font(.system(size: 16))
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            Text(String(format: "%.1f kg", max))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(color)
        }
    }
}

// MARK: - Info Section
struct ProfileInfoSection: View {
    @ObservedObject var dataManager: DataManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Informazioni")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            VStack(spacing: 12) {
                ProfileInfoRow(icon: "person.fill", title: "Peso Corporeo", value: String(format: "%.1f kg", dataManager.userProfile.bodyweight))
                
                ProfileInfoRow(icon: "ruler.fill", title: "Altezza", value: String(format: "%.0f cm", dataManager.userProfile.height))
                
                if dataManager.userProfile.age > 0 {
                    ProfileInfoRow(icon: "calendar", title: "Età", value: "\(dataManager.userProfile.age) anni")
                }
                
                if !dataManager.userProfile.email.isEmpty {
                    ProfileInfoRow(icon: "envelope.fill", title: "Email", value: dataManager.userProfile.email)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.cardBackground)
            )
        }
    }
}

struct ProfileInfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(AppColors.primary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
                
                Text(value)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.textPrimary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Edit Profile View
struct EditProfileView: View {
    @ObservedObject var dataManager: DataManager
    @Binding var isPresented: Bool
    
    @State private var name: String
    @State private var email: String
    @State private var bodyweight: String
    @State private var height: String
    @State private var age: String
    @State private var squatMax: String
    @State private var benchMax: String
    @State private var deadliftMax: String
    @State private var athleteLevel: AthleteLevel
    
    init(dataManager: DataManager, isPresented: Binding<Bool>) {
        self.dataManager = dataManager
        self._isPresented = isPresented
        
        _name = State(initialValue: dataManager.userProfile.name)
        _email = State(initialValue: dataManager.userProfile.email)
        _bodyweight = State(initialValue: String(format: "%.1f", dataManager.userProfile.bodyweight))
        _height = State(initialValue: String(format: "%.0f", dataManager.userProfile.height))
        _age = State(initialValue: dataManager.userProfile.age > 0 ? "\(dataManager.userProfile.age)" : "")
        _squatMax = State(initialValue: String(format: "%.1f", dataManager.userProfile.squatMax))
        _benchMax = State(initialValue: String(format: "%.1f", dataManager.userProfile.benchMax))
        _deadliftMax = State(initialValue: String(format: "%.1f", dataManager.userProfile.deadliftMax))
        _athleteLevel = State(initialValue: dataManager.userProfile.athleteLevel)
    }
    
    var totalMax: Double {
        let squat = Double(squatMax) ?? 0
        let bench = Double(benchMax) ?? 0
        let deadlift = Double(deadliftMax) ?? 0
        return squat + bench + deadlift
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Informazioni Personali
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Informazioni Personali")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            VStack(spacing: 16) {
                                ProfileTextField(icon: "person.fill", placeholder: "Nome", text: $name)
                                ProfileTextField(icon: "envelope.fill", placeholder: "Email", text: $email)
                                ProfileTextField(icon: "scalemass.fill", placeholder: "Peso (kg)", text: $bodyweight, keyboardType: .decimalPad)
                                ProfileTextField(icon: "ruler.fill", placeholder: "Altezza (cm)", text: $height, keyboardType: .numberPad)
                                ProfileTextField(icon: "calendar", placeholder: "Età", text: $age, keyboardType: .numberPad)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Livello Atleta
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Livello")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Picker("Livello", selection: $athleteLevel) {
                                ForEach([AthleteLevel.beginner, .intermediate, .advanced, .elite], id: \.self) { level in
                                    Text(level.displayName).tag(level)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(.horizontal, 20)
                        
                        // Massimali
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Massimali")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            VStack(spacing: 16) {
                                ProfileTextField(icon: "🏋️", placeholder: "Squat Max (kg)", text: $squatMax, keyboardType: .decimalPad)
                                ProfileTextField(icon: "💪", placeholder: "Panca Max (kg)", text: $benchMax, keyboardType: .decimalPad)
                                ProfileTextField(icon: "🔥", placeholder: "Stacco Max (kg)", text: $deadliftMax, keyboardType: .decimalPad)
                            }
                            
                            // Totale Live
                            HStack {
                                Text("💎 Totale")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(AppColors.textPrimary)
                                
                                Spacer()
                                
                                Text(String(format: "%.1f kg", totalMax))
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(AppColors.primary)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(AppColors.primary.opacity(0.1))
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Modifica Profilo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annulla") {
                        isPresented = false
                    }
                    .foregroundColor(AppColors.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salva") {
                        saveProfile()
                    }
                    .foregroundColor(AppColors.primary)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func saveProfile() {
        var updatedProfile = dataManager.userProfile
        
        updatedProfile.name = name.isEmpty ? "Atleta" : name
        updatedProfile.email = email
        updatedProfile.bodyweight = Double(bodyweight) ?? updatedProfile.bodyweight
        updatedProfile.height = Double(height) ?? updatedProfile.height
        updatedProfile.age = Int(age) ?? 0
        updatedProfile.squatMax = Double(squatMax) ?? updatedProfile.squatMax
        updatedProfile.benchMax = Double(benchMax) ?? updatedProfile.benchMax
        updatedProfile.deadliftMax = Double(deadliftMax) ?? updatedProfile.deadliftMax
        updatedProfile.athleteLevel = athleteLevel
        
        dataManager.saveProfile(updatedProfile)
        isPresented = false
    }
}

// MARK: - Profile Text Field
struct ProfileTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack(spacing: 12) {
            if icon.count == 1 {
                Text(icon)
                    .font(.system(size: 20))
                    .frame(width: 24)
            } else {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.primary)
                    .frame(width: 24)
            }
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .foregroundColor(AppColors.textPrimary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.cardBackground)
        )
    }
}
