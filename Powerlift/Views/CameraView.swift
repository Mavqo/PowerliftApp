import SwiftUI
import AVFoundation
import Combine  // ✅ AGGIUNGI QUESTA RIGA

struct CameraView: View {
    @ObservedObject var dataManager: DataManager
    @State private var isRecording = false
    @State private var showingAnalysis = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack {
                Text("Camera")
                    .font(.largeTitle.bold())
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.top, 60)
                
                Spacer()
                
                // Placeholder Camera Preview
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(AppColors.cardBackground)
                        .frame(height: 400)
                    
                    VStack(spacing: 20) {
                        Image(systemName: "video.fill")
                            .font(.system(size: 80))
                            .foregroundColor(AppColors.primary)
                        
                        Text("Analisi Video")
                            .font(.title2.bold())
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("Coming Soon")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Record Button
                Button(action: {
                    isRecording.toggle()
                }) {
                    ZStack {
                        Circle()
                            .fill(isRecording ? AppColors.error : AppColors.primary)
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                            .frame(width: 90, height: 90)
                        
                        if isRecording {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white)
                                .frame(width: 30, height: 30)
                        } else {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 35, height: 35)
                        }
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }
}
