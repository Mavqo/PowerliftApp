import SwiftUI

struct OnboardingView: View {
    @ObservedObject var dataManager: DataManager
    @State private var currentPage = 0
    @State private var name = ""
    @State private var bodyweight = ""
    @State private var athleteLevel: AthleteLevel = .beginner
    @State private var squatMax = ""
    @State private var benchMax = ""
    @State private var deadliftMax = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                // Page 1: Welcome
                WelcomePage()
                    .tag(0)
                
                // Page 2: Profile Info
                ProfileInfoPage(
                    name: $name,
                    bodyweight: $bodyweight,
                    athleteLevel: $athleteLevel
                )
                .tag(1)
                
                // Page 3: PRs
                PRsPage(
                    squatMax: $squatMax,
                    benchMax: $benchMax,
                    deadliftMax: $deadliftMax
                )
                .tag(2)
                
                // Page 4: Ready
                ReadyPage()
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            VStack {
                Spacer()
                
                Button(action: {
                    if currentPage < 3 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        completeOnboarding()
                    }
                }) {
                    Text(currentPage == 3 ? "Inizia" : "Continua")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AppColors.primary)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }
    
    private func completeOnboarding() {
        var profile = dataManager.userProfile
        profile.name = name
        profile.bodyweight = Double(bodyweight) ?? 0
        profile.athleteLevel = athleteLevel
        profile.squatMax = Double(squatMax) ?? 0
        profile.benchMax = Double(benchMax) ?? 0
        profile.deadliftMax = Double(deadliftMax) ?? 0
        
        dataManager.saveProfile(profile)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Welcome Page
struct WelcomePage: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 100))
                .foregroundColor(AppColors.primary)
            
            Text("Benvenuto in Powerlift")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)
            
            Text("Traccia i tuoi progressi\nAnalizza i tuoi lift\nMigliora costantemente")
                .font(.system(size: 18))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(8)
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - Profile Info Page
struct ProfileInfoPage: View {
    @Binding var name: String
    @Binding var bodyweight: String
    @Binding var athleteLevel: AthleteLevel
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Il tuo Profilo")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
                .padding(.top, 60)
            
            VStack(spacing: 20) {
                OnboardingTextField(title: "Nome", text: $name, placeholder: "Il tuo nome")
                
                OnboardingTextField(title: "Peso (kg)", text: $bodyweight, placeholder: "70.0")
                    .keyboardType(.decimalPad)
            }
            .padding(.horizontal, 40)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Livello Atleta")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.horizontal, 40)
                
                VStack(spacing: 12) {
                    ForEach(AthleteLevel.allCases, id: \.self) { level in
                        OnboardingLevelCard(
                            level: level,
                            isSelected: athleteLevel == level
                        ) {
                            athleteLevel = level
                        }
                    }
                }
                .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
}

// MARK: - PRs Page
struct PRsPage: View {
    @Binding var squatMax: String
    @Binding var benchMax: String
    @Binding var deadliftMax: String
    
    var body: some View {
        VStack(spacing: 30) {
            Text("I tuoi PR")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
                .padding(.top, 60)
            
            Text("Inserisci i tuoi massimali (1RM)")
                .font(.system(size: 16))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 20) {
                OnboardingTextField(title: "Squat Max (kg)", text: $squatMax, placeholder: "100")
                    .keyboardType(.decimalPad)
                
                OnboardingTextField(title: "Bench Press Max (kg)", text: $benchMax, placeholder: "80")
                    .keyboardType(.decimalPad)
                
                OnboardingTextField(title: "Deadlift Max (kg)", text: $deadliftMax, placeholder: "120")
                    .keyboardType(.decimalPad)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

// MARK: - Ready Page
struct ReadyPage: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(AppColors.success)
            
            Text("Tutto Pronto!")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
            
            Text("Inizia a tracciare i tuoi allenamenti\ne raggiungi i tuoi obiettivi")
                .font(.system(size: 18))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(8)
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - Onboarding TextField
struct OnboardingTextField: View {
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

// MARK: - Onboarding Level Card
struct OnboardingLevelCard: View {
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
                
                ZStack {
                    Circle()
                        .stroke(isSelected ? AppColors.primary : AppColors.textSecondary.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(AppColors.primary)
                            .frame(width: 14, height: 14)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? AppColors.primary.opacity(0.1) : AppColors.cardBackground)
            )
        }
    }
}
