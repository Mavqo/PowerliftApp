import SwiftUI
import AVFoundation
import Combine

struct VideoAnalysisView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var dataManager: DataManager
    
    let videoURL: URL
    
    @State private var isPlaying = false
    @State private var currentTime: Double = 0
    @State private var duration: Double = 1
    @State private var showStats = true
    
    @State private var avgVelocity: Double = 0.85
    @State private var maxVelocity: Double = 1.20
    @State private var rom: Double = 45.5
    
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
                    
                    Text("Analisi Video")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Button(action: {
                        saveAnalysis()
                    }) {
                        Text("Salva")
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
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("Video Preview")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        
                        Text(videoURL.lastPathComponent)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    if showStats {
                        VStack {
                            Spacer()
                            VideoStatsOverlay(
                                avgVelocity: avgVelocity,
                                maxVelocity: maxVelocity,
                                rom: rom
                            )
                            .padding(.bottom, 80)
                        }
                    }
                }
                .frame(maxHeight: .infinity)
                
                // MARK: - Controls
                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        HStack {
                            Text(formatTime(currentTime))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(AppColors.textSecondary)
                            
                            Spacer()
                            
                            Text(formatTime(duration))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        Slider(value: $currentTime, in: 0...duration)
                            .accentColor(AppColors.primary)
                    }
                    .padding(.horizontal, 20)
                    
                    HStack(spacing: 30) {
                        Button(action: {}) {
                            Image(systemName: "gobackward.5")
                                .font(.system(size: 24))
                                .foregroundColor(AppColors.textPrimary)
                        }
                        
                        Button(action: {
                            isPlaying.toggle()
                        }) {
                            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(AppColors.primary)
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "goforward.5")
                                .font(.system(size: 24))
                                .foregroundColor(AppColors.textPrimary)
                        }
                    }
                    .padding(.bottom, 10)
                    
                    Button(action: {
                        showStats.toggle()
                    }) {
                        HStack {
                            Image(systemName: showStats ? "eye.fill" : "eye.slash.fill")
                            Text(showStats ? "Nascondi Stats" : "Mostra Stats")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(AppColors.textSecondary)
                    }
                }
                .padding(.vertical, 20)
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
    
    private func saveAnalysis() {
        let stats = WorkoutStats(
            exerciseType: "Squat",
            avgVelocity: avgVelocity,
            maxVelocity: maxVelocity,
            rom: rom,
            totalReps: 1
        )
        
        dataManager.addWorkoutFromVideo(url: videoURL, stats: stats)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Video Stats Overlay
struct VideoStatsOverlay: View {
    let avgVelocity: Double
    let maxVelocity: Double
    let rom: Double
    
    var body: some View {
        HStack(spacing: 12) {
            VideoStatCard(
                icon: "speedometer",
                value: String(format: "%.2f", avgVelocity),
                unit: "m/s",
                title: "Avg Vel",
                color: AppColors.statVelocity
            )
            
            VideoStatCard(
                icon: "bolt.fill",
                value: String(format: "%.2f", maxVelocity),
                unit: "m/s",
                title: "Max Vel",
                color: AppColors.primary
            )
            
            VideoStatCard(
                icon: "arrow.up.and.down",
                value: String(format: "%.1f", rom),
                unit: "cm",
                title: "ROM",
                color: AppColors.statROM
            )
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Video Stat Card
struct VideoStatCard: View {
    let icon: String
    let value: String
    let unit: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Text(unit)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Text(title)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.backgroundElevated.opacity(0.9))
        )
    }
}
