import SwiftUI

struct ProfileView: View {
    @ObservedObject var dataManager: DataManager
    @State private var isEditing = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header con Avatar
                    ProfileHeader(dataManager: dataManager)
                        .padding(.top, 20)
                    
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
                        .background(AppColors.primary)
                        .cornerRadius(16)
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
    }
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
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.primary, AppColors.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Text(initials)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
            }
            .shadow(color: AppColors.primary.opacity(0.3), radius: 20, x: 0, y: 10)
            
            // Nome
            Text(dataManager.userProfile.name)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            // Livello
            Text(dataManager.userProfile.athleteLevel.displayName)
                .font(.system(size: 16))
                .foregroundColor(AppColors.textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(AppColors.primary.opacity(0.2))
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
                .fill(color.opacity(0.1))
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
                                CustomTextField(icon: "person.fill", placeholder: "Nome", text: $name)
                                CustomTextField(icon: "envelope.fill", placeholder: "Email", text: $email)
                                CustomTextField(icon: "scalemass.fill", placeholder: "Peso (kg)", text: $bodyweight, keyboardType: .decimalPad)
                                CustomTextField(icon: "ruler.fill", placeholder: "Altezza (cm)", text: $height, keyboardType: .numberPad)
                                CustomTextField(icon: "calendar", placeholder: "Età", text: $age, keyboardType: .numberPad)
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
                                CustomTextField(icon: "🏋️", placeholder: "Squat Max (kg)", text: $squatMax, keyboardType: .decimalPad)
                                CustomTextField(icon: "💪", placeholder: "Panca Max (kg)", text: $benchMax, keyboardType: .decimalPad)
                                CustomTextField(icon: "🔥", placeholder: "Stacco Max (kg)", text: $deadliftMax, keyboardType: .decimalPad)
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

struct CustomTextField: View {
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
        }
    }
}
