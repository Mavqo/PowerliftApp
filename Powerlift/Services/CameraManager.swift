import Foundation
import Combine
import AVFoundation
import Vision


class CameraManager: NSObject, ObservableObject {
    let captureSession = AVCaptureSession()
    private var videoOutput: AVCaptureMovieFileOutput?
    private var recordingURL: URL?
    
    @Published var currentBarVelocity: Double?
    private let dataManager: DataManager
    
    private var lastBarPosition: CGPoint?
    private var lastFrameTime: Date?
    private var detectionRequest: VNDetectRectanglesRequest?
    
    init(dataManager: DataManager) {
        self.dataManager = dataManager
        super.init()
        setupCamera()
        setupVision()
    }
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { _ in }
        default:
            break
        }
    }
    
    private func setupCamera() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .high
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              captureSession.canAddInput(videoInput) else {
            return
        }
        
        captureSession.addInput(videoInput)
        
        let output = AVCaptureMovieFileOutput()
        output.movieFragmentInterval = .invalid
        
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
            videoOutput = output
        }
        
        captureSession.commitConfiguration()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    private func setupVision() {
        detectionRequest = VNDetectRectanglesRequest { [weak self] request, error in
            guard let results = request.results as? [VNRectangleObservation],
                  let firstRect = results.first else {
                return
            }
            
            self?.trackBarMovement(barPosition: firstRect.boundingBox.origin)
        }
        
        detectionRequest?.minimumAspectRatio = 0.3
        detectionRequest?.maximumAspectRatio = 0.7
    }
    
    private func trackBarMovement(barPosition: CGPoint) {
        let currentTime = Date()
        
        defer {
            lastBarPosition = barPosition
            lastFrameTime = currentTime
        }
        
        guard let lastPos = lastBarPosition,
              let lastTime = lastFrameTime else {
            return
        }
        
        let deltaY = barPosition.y - lastPos.y
        let deltaTime = currentTime.timeIntervalSince(lastTime)
        
        guard deltaTime > 0 else { return }
        
        let pixelToMeter: Double = 0.002
        let velocity = abs(deltaY * pixelToMeter / deltaTime)
        
        DispatchQueue.main.async {
            self.currentBarVelocity = velocity
        }
    }
    
    func startRecording() {
        guard let output = videoOutput else { return }
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let fileUrl = paths[0].appendingPathComponent("lift_\(Date().timeIntervalSince1970).mov")
        recordingURL = fileUrl
        
        output.startRecording(to: fileUrl, recordingDelegate: self)
    }
    
    func stopRecording(completion: @escaping (URL?) -> Void) {
        videoOutput?.stopRecording()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            completion(self.recordingURL)
        }
    }
}

extension CameraManager: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Recording error: \(error.localizedDescription)")
        }
    }
}
