import SwiftUI
import Combine

struct ProfileEditView: View {
    @ObservedObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var bodyweight: String = ""
    @State private var height: String = ""
    @State private var age: String = ""
    @State private var athleteLevel: AthleteLevel = .beginner
    @State private var benchMax: String = ""
    @State private var squatMax: String = ""
    @State private var deadliftMax: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Icon
                        Circle()
                            .fill(AppColors.primary.opacity(0.2))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(AppColors.primary)
                            )
                            .padding(.top, 20)
                        
                        // Form Fields
                        VStack(spacing: 20) {
                            // Personal Info
                            SectionHeader(title: "Informazioni Personali")
                            
                            CustomTextField(title: "Nome", text: $name, placeholder: "Il tuo nome")
                            CustomTextField(title: "Email", text: $email, placeholder: "email@example.com")
                                .keyboardType(.emailAddress)
                            
                            HStack(spacing: 12) {
                                CustomTextField(title: "Età", text: $age, placeholder: "25")
                                    .keyboardType(.numberPad)
                                
                                CustomTextField(title: "Altezza (cm)", text: $height, placeholder: "175")
                                    .keyboardType(.decimalPad)
                            }
                            
                            CustomTextField(title: "Peso (kg)", text: $bodyweight, placeholder: "70.0")
                                .keyboardType(.decimalPad)
                            
                            // Athlete Level
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Livello Atleta")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.textSecondary)
                                    .padding(.horizontal, 20)
                                
                                VStack(spacing: 12) {
                                    ForEach(AthleteLevel.allCases, id: \.self) { level in
                                        LevelCard(
                                            level: level,
                                            isSelected: athleteLevel == level
                                        ) {
                                            athleteLevel = level
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            
                            // PR Section
                            SectionHeader(title: "Personal Records (1RM)")
                            
                            CustomTextField(title: "Squat Max (kg)", text: $squatMax, placeholder: "100")
                                .keyboardType(.decimalPad)
                            
                            CustomTextField(title: "Bench Press Max (kg)", text: $benchMax, placeholder: "80")
                                .keyboardType(.decimalPad)
                            
                            CustomTextField(title: "Deadlift Max (kg)", text: $deadliftMax, placeholder: "120")
                                .keyboardType(.decimalPad)
                            
                            // Total Display
                            if let total = calculateTotal() {
                                TotalCard(total: total)
                                    .padding(.horizontal, 20)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("Profilo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annulla") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(AppColors.primary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salva") {
                        saveProfile()
                    }
                    .foregroundColor(AppColors.primary)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                loadCurrentProfile()
            }
        }
    }
    
    private func loadCurrentProfile() {
        name = dataManager.userProfile.name
        email = dataManager.userProfile.email
        bodyweight = String(format: "%.1f", dataManager.userProfile.bodyweight)
        height = String(format: "%.0f", dataManager.userProfile.height)
        age = dataManager.userProfile.age > 0 ? String(dataManager.userProfile.age) : ""
        athleteLevel = dataManager.userProfile.athleteLevel
        benchMax = String(format: "%.1f", dataManager.userProfile.benchMax)
        squatMax = String(format: "%.1f", dataManager.userProfile.squatMax)
        deadliftMax = String(format: "%.1f", dataManager.userProfile.deadliftMax)
    }
    
    private func saveProfile() {
        var updatedProfile = dataManager.userProfile
        updatedProfile.name = name
        updatedProfile.email = email
        updatedProfile.bodyweight = Double(bodyweight) ?? 0.0
        updatedProfile.height = Double(height) ?? 0.0
        updatedProfile.age = Int(age) ?? 0
        updatedProfile.athleteLevel = athleteLevel
        updatedProfile.benchMax = Double(benchMax) ?? 0.0
        updatedProfile.squatMax = Double(squatMax) ?? 0.0
        updatedProfile.deadliftMax = Double(deadliftMax) ?? 0.0
        
        dataManager.saveProfile(updatedProfile)
        presentationMode.wrappedValue.dismiss()
    }
    
    private func calculateTotal() -> Double? {
        guard let squat = Double(squatMax),
              let bench = Double(benchMax),
              let deadlift = Double(deadliftMax),
              squat > 0 || bench > 0 || deadlift > 0 else {
            return nil
        }
        return squat + bench + deadlift
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(AppColors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 8)
    }
}

// MARK: - Level Card
struct LevelCard: View {
    let level: AthleteLevel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.displayName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isSelected ? AppColors.textPrimary : AppColors.textSecondary)
                    
                    Text(level.description)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppColors.primary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? AppColors.primary.opacity(0.1) : AppColors.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? AppColors.primary : Color.clear, lineWidth: 2)
            )
        }
    }
}

// MARK: - Total Card
struct TotalCard: View {
    let total: Double
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.primary)
            
            VStack(spacing: 8) {
                Text("TOTALE")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
                
                Text(String(format: "%.1f kg", total))
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding()
        }
        .frame(height: 100)
    }
}

// MARK: - Custom TextField
struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
            
            TextField(placeholder, text: $text)
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(12)
                .foregroundColor(AppColors.textPrimary)
                .keyboardType(keyboardType)
        }
    }
}
