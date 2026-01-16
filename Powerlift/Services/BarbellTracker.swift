import Foundation
import Vision
import AVFoundation
import CoreGraphics
import Combine

class BarbellTracker: ObservableObject {
    @Published var currentVelocity: Double = 0.0
    @Published var avgVelocity: Double = 0.0
    @Published var peakVelocity: Double = 0.0
    @Published var barPath: [CGPoint] = []
    @Published var isTracking: Bool = false
    @Published var rom: Double = 0.0
    
    private var lastPosition: CGPoint?
    private var lastTimestamp: TimeInterval?
    private var velocities: [Double] = []
    private var initialY: CGFloat?
    
    private let plateDiameterCM: Double = 45.0
    private var pixelsPerCM: Double = 1.0
    
    private var trackingRequest: VNTrackObjectRequest?
    private let visionQueue = DispatchQueue(label: "com.powerlift.vision")
    
    func startTracking(initialRect: CGRect, in imageSize: CGSize) {
        let observation = VNDetectedObjectObservation(boundingBox: initialRect)
        let request = VNTrackObjectRequest(detectedObjectObservation: observation)
        
        request.trackingLevel = .accurate
        trackingRequest = request
        
        isTracking = true
        barPath.removeAll()
        velocities.removeAll()
        lastPosition = nil
        lastTimestamp = nil
        initialY = nil
        
        let rectHeight = initialRect.height * imageSize.height
        pixelsPerCM = rectHeight / plateDiameterCM
    }
    
    func trackFrame(_ pixelBuffer: CVPixelBuffer, timestamp: TimeInterval) {
        guard isTracking, let request = trackingRequest else { return }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        
        visionQueue.async { [weak self] in
            do {
                try handler.perform([request])
                
                if let observation = request.results?.first as? VNDetectedObjectObservation {
                    DispatchQueue.main.async {
                        self?.processObservation(observation, timestamp: timestamp)
                    }
                }
            } catch {
                print("Vision tracking error: \(error)")
            }
        }
    }
    
    private func processObservation(_ observation: VNDetectedObjectObservation, timestamp: TimeInterval) {
        let boundingBox = observation.boundingBox
        let center = CGPoint(
            x: boundingBox.midX,
            y: boundingBox.midY
        )
        
        barPath.append(center)
        
        if let lastPos = lastPosition, let lastTime = lastTimestamp {
            let deltaY = (center.y - lastPos.y) * 1000
            let deltaTime = timestamp - lastTime
            
            if deltaTime > 0 {
                let velocityCMPerSec = (deltaY / pixelsPerCM) / deltaTime
                let velocityMPerSec = velocityCMPerSec / 100.0
                
                currentVelocity = abs(velocityMPerSec)
                velocities.append(currentVelocity)
                
                avgVelocity = velocities.reduce(0, +) / Double(velocities.count)
                peakVelocity = velocities.max() ?? 0
            }
        }
        
        if initialY == nil {
            initialY = center.y
        }
        if let initY = initialY {
            let deltaPixels = abs(center.y - initY) * 1000
            rom = deltaPixels / pixelsPerCM
        }
        
        lastPosition = center
        lastTimestamp = timestamp
    }
    
    func stopTracking() {
        isTracking = false
        trackingRequest = nil
    }
    
    func reset() {
        stopTracking()
        barPath.removeAll()
        velocities.removeAll()
        currentVelocity = 0
        avgVelocity = 0
        peakVelocity = 0
        rom = 0
        lastPosition = nil
        lastTimestamp = nil
        initialY = nil
    }
    
    func getColorForVelocity(_ velocity: Double) -> String {
        if velocity > 1.0 {
            return "00d4aa"
        } else if velocity > 0.5 {
            return "d4ff00"
        } else {
            return "ff6b6b"
        }
    }
}
