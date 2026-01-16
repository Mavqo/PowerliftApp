import SwiftUI
import Combine

struct WarmupView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @Environment(\.presentationMode) var presentationMode
    
    let exerciseType: ExerciseType
    let workingWeight: Double
    
    @State private var warmupSets: [WarmupSet] = []
    @State private var currentSetIndex = 0
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Header
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    Text("Riscaldamento")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Button(action: {
                        finishWarmup()
                    }) {
                        Text("Fine")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.primary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(AppColors.backgroundElevated)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Exercise Info
                        VStack(spacing: 8) {
                            Image(systemName: exerciseType.icon)
                                .font(.system(size: 50))
                                .foregroundColor(AppColors.primary)
                            
                            Text(exerciseType.displayName)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            Text("Target: \(String(format: "%.1f", workingWeight)) kg")
                                .font(.system(size: 16))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding(.top, 30)
                        
                        // Progress Bar
                        ProgressBar(current: currentSetIndex, total: warmupSets.count)
                            .padding(.horizontal, 20)
                        
                        // Warmup Sets List
                        VStack(spacing: 12) {
                            ForEach(Array(warmupSets.enumerated()), id: \.element.id) { index, set in
                                WarmupSetRow(
                                    set: set,
                                    index: index,
                                    isActive: index == currentSetIndex,
                                    onComplete: {
                                        completeSet(at: index)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
        }
        .onAppear {
            warmupSets = viewModel.generateWarmupSets(for: exerciseType, workingWeight: workingWeight)
        }
        .navigationBarHidden(true)
    }
    
    private func completeSet(at index: Int) {
        guard index < warmupSets.count else { return }
        warmupSets[index].completed = true
        
        if index < warmupSets.count - 1 {
            currentSetIndex = index + 1
        }
    }
    
    private func finishWarmup() {
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Progress Bar
struct ProgressBar: View {
    let current: Int
    let total: Int
    
    var progress: CGFloat {
        guard total > 0 else { return 0 }
        return CGFloat(current) / CGFloat(total)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppColors.cardBackground)
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppColors.primary)
                        .frame(width: geometry.size.width * progress, height: 12)
                }
            }
            .frame(height: 12)
            
            Text("\(current) di \(total) completati")
                .font(.system(size: 14))
                .foregroundColor(AppColors.textSecondary)
        }
    }
}

// MARK: - Warmup Set Row
struct WarmupSetRow: View {
    let set: WarmupSet
    let index: Int
    let isActive: Bool
    let onComplete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Set Number
            ZStack {
                Circle()
                    .fill(set.completed ? AppColors.success : isActive ? AppColors.primary : AppColors.cardBackground)
                    .frame(width: 40, height: 40)
                
                if set.completed {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text("\(index + 1)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(isActive ? .white : AppColors.textSecondary)
                }
            }
            
            // Set Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(String(format: "%.1f", set.weight)) kg")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("× \(set.reps)")
                        .font(.system(size: 18))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                if set.percentage > 0 {
                    Text("\(set.percentage)% del massimale")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            Spacer()
            
            // Complete Button
            if isActive && !set.completed {
                Button(action: onComplete) {
                    Text("Fatto")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(AppColors.primary)
                        .cornerRadius(20)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isActive ? AppColors.primary.opacity(0.1) : AppColors.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isActive ? AppColors.primary : Color.clear, lineWidth: 2)
                )
        )
    }
}
