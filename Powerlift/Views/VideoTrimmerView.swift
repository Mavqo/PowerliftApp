import SwiftUI
import AVFoundation
import Combine

struct VideoTrimmerView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let videoURL: URL
    let onTrimComplete: (URL) -> Void
    
    @State private var startTime: Double = 0
    @State private var endTime: Double = 10
    @State private var duration: Double = 10
    @State private var currentTime: Double = 0
    @State private var isPlaying = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Header
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Annulla")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    
                    Spacer()
                    
                    Text("Taglia Video")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Button(action: {
                        trimVideo()
                    }) {
                        Text("Fatto")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.primary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(AppColors.backgroundElevated)
                
                // MARK: - Video Preview
                ZStack {
                    Rectangle()
                        .fill(Color.black)
                    
                    VStack(spacing: 20) {
                        Image(systemName: "video.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("Preview")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                    }
                }
                .frame(maxHeight: .infinity)
                
                // MARK: - Trimmer Controls
                VStack(spacing: 24) {
                    // Timeline
                    VStack(spacing: 12) {
                        HStack {
                            Text("Inizio: \(formatTime(startTime))")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textSecondary)
                            
                            Spacer()
                            
                            Text("Fine: \(formatTime(endTime))")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        // Start Time Slider
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Punto di inizio")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.textSecondary)
                            
                            Slider(value: $startTime, in: 0...duration)
                                .accentColor(AppColors.primary)
                        }
                        
                        // End Time Slider
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Punto di fine")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.textSecondary)
                            
                            Slider(value: $endTime, in: startTime...duration)
                                .accentColor(AppColors.primary)
                        }
                        
                        // Duration Display
                        HStack {
                            Spacer()
                            Text("Durata: \(formatTime(endTime - startTime))")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppColors.primary)
                            Spacer()
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 20)
                    
                    // Play Button
                    Button(action: {
                        isPlaying.toggle()
                    }) {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(AppColors.primary)
                    }
                }
                .padding(.vertical, 24)
                .background(AppColors.backgroundElevated)
            }
        }
        .navigationBarHidden(true)
    }
    
    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func trimVideo() {
        // Per ora ritorna il video originale
        // In futuro implementeremo il trim effettivo
        onTrimComplete(videoURL)
        presentationMode.wrappedValue.dismiss()
    }
}
