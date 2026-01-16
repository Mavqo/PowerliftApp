import SwiftUI

struct ManualWorkoutCreatorView: View {
    @ObservedObject var dataManager: DataManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedDate = Date()
    @State private var selectedExercise: ExerciseType = .squat
    @State private var sets: [ManualSet] = []
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Date Picker
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Data Allenamento")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .accentColor(AppColors.primary)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(AppColors.cardBackground)
                                )
                        }
                        .padding(.horizontal, 20)
                        
                        // Exercise Picker
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Esercizio")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            HStack(spacing: 12) {
                                ForEach(ExerciseType.allCases, id: \.self) { exercise in
                                    ExercisePickerButton(
                                        exercise: exercise,
                                        isSelected: selectedExercise == exercise
                                    ) {
                                        selectedExercise = exercise
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Sets Builder
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Serie")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(AppColors.textPrimary)
                                
                                Spacer()
                                
                                Button(action: addSet) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Aggiungi")
                                    }
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppColors.primary)
                                }
                            }
                            
                            if sets.isEmpty {
                                EmptySetState {
                                    addSet()
                                }
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(Array(sets.enumerated()), id: \.element.id) { index, set in
                                        ManualSetRow(
                                            setNumber: index + 1,
                                            set: $sets[index],
                                            onDelete: {
                                                sets.remove(at: index)
                                            }
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Notes
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Note (opzionale)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            TextEditor(text: $notes)
                                .frame(height: 100)
                                .padding(12)
                                .background(AppColors.cardBackground)
                                .cornerRadius(12)
                                .foregroundColor(AppColors.textPrimary)
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.vertical, 20)
                }
                
                // Save Button (floating)
                VStack {
                    Spacer()
                    
                    Button(action: saveWorkout) {
                        Text("Salva Allenamento")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.primary)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .disabled(sets.isEmpty)
                    .opacity(sets.isEmpty ? 0.5 : 1.0)
                }
            }
            .navigationTitle("Nuovo Allenamento")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annulla") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(AppColors.textPrimary)
                }
            }
        }
    }
    
    private func addSet() {
        sets.append(ManualSet(reps: 5, percentage: 75, rest: 180))
    }
    
    private func saveWorkout() {
        let plannedSets = sets.enumerated().map { index, set in
            PlannedSet(
                setNumber: index + 1,
                weight: nil,
                percentage: set.percentage,
                reps: set.reps,
                targetRPE: set.rpe,
                restSeconds: set.rest
            )
        }
        
        let workout = WorkoutPlan(
            date: selectedDate,
            exerciseType: selectedExercise,
            sets: plannedSets,
            warmupRequired: true,
            notes: notes.isEmpty ? nil : notes
        )
        
        dataManager.addWorkoutPlan(workout)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Manual Set Model
struct ManualSet: Identifiable {
    let id = UUID()
    var reps: Int
    var percentage: Int?
    var rpe: Double?
    var rest: Int
}

// MARK: - Exercise Picker Button
struct ExercisePickerButton: View {
    let exercise: ExerciseType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(exercise.emoji)
                    .font(.system(size: 32))
                
                Text(exercise.displayName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(isSelected ? AppColors.textPrimary : AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? AppColors.primary.opacity(0.2) : AppColors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? AppColors.primary : Color.clear, lineWidth: 2)
                    )
            )
        }
    }
}

// MARK: - Manual Set Row
struct ManualSetRow: View {
    let setNumber: Int
    @Binding var set: ManualSet
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Serie \(setNumber)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.error)
                }
            }
            
            HStack(spacing: 12) {
                // Reps
                VStack(alignment: .leading, spacing: 4) {
                    Text("Reps")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                    
                    Stepper("\(set.reps)", value: $set.reps, in: 1...20)
                        .labelsHidden()
                        .frame(width: 100)
                }
                
                // Percentage
                VStack(alignment: .leading, spacing: 4) {
                    Text("% Max")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                    
                    Stepper("\(set.percentage ?? 0)%", value: Binding(
                        get: { set.percentage ?? 70 },
                        set: { set.percentage = $0 }
                    ), in: 40...100, step: 5)
                    .labelsHidden()
                    .frame(width: 100)
                }
                
                // Rest
                VStack(alignment: .leading, spacing: 4) {
                    Text("Rest (s)")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                    
                    Stepper("\(set.rest)", value: $set.rest, in: 30...600, step: 30)
                        .labelsHidden()
                        .frame(width: 100)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.cardBackground)
        )
    }
}

// MARK: - Empty Set State
struct EmptySetState: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 50))
                    .foregroundColor(AppColors.textSecondary.opacity(0.5))
                
                Text("Aggiungi la prima serie")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [5]))
                            .foregroundColor(AppColors.textSecondary.opacity(0.3))
                    )
            )
        }
    }
}
