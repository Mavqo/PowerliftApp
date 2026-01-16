import Foundation
import AVFoundation
import Vision
import Combine
import PhotosUI
import UIKit

class CameraViewModel: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var isCameraReady = false
    @Published var showTrackingSelector = false
    @Published var recordedVideoURL: URL?
    @Published var barbellWeight: String = "100"
    @Published var isProcessingVideo = false
    @Published var processingProgress: Double = 0.0
    @Published var showVideoPicker = false
    
    let barbellTracker = BarbellTracker()
    
    private var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureMovieFileOutput?
    private var videoDataOutput: AVCaptureVideoDataOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    private let sessionQueue = DispatchQueue(label: "com.powerlift.camera")
    private let dataOutputQueue = DispatchQueue(label: "com.powerlift.videodata")
    
    // MARK: - Setup Camera
    func setupCamera() {
        sessionQueue.async { [weak self] in
            self?.configureCaptureSession()
        }
    }
    
    private func configureCaptureSession() {
        let session = AVCaptureSession()
        session.beginConfiguration()
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            print("Camera not available")
            return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        let movieOutput = AVCaptureMovieFileOutput()
        if session.canAddOutput(movieOutput) {
            session.addOutput(movieOutput)
            videoOutput = movieOutput
        }
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
        dataOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        
        if session.canAddOutput(dataOutput) {
            session.addOutput(dataOutput)
            videoDataOutput = dataOutput
        }
        
        session.sessionPreset = .high
        session.commitConfiguration()
        
        captureSession = session
        
        DispatchQueue.main.async {
            self.isCameraReady = true
        }
        
        session.startRunning()
    }
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        guard let session = captureSession else { return nil }
        
        if previewLayer == nil {
            let layer = AVCaptureVideoPreviewLayer(session: session)
            layer.videoGravity = .resizeAspectFill
            previewLayer = layer
        }
        
        return previewLayer
    }
    
    // MARK: - Recording
    func startRecording() {
        guard let output = videoOutput, !output.isRecording else { return }
        
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mov")
        
        output.startRecording(to: tempURL, recordingDelegate: self)
        isRecording = true
    }
    
    func stopRecording() {
        videoOutput?.stopRecording()
        barbellTracker.stopTracking()
    }
    
    // MARK: - Barbell Selection
    func selectBarbellArea(_ rect: CGRect) {
        guard let previewLayer = previewLayer else { return }
        
        let videoRect = previewLayer.metadataOutputRectConverted(fromLayerRect: rect)
        
        guard let connection = videoDataOutput?.connection(with: .video),
              let formatDescription = connection.videoPreviewLayer?.connection?.videoPreviewLayer?.connection?.inputPorts.first?.formatDescription else {
            return
        }
        
        let dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)
        let imageSize = CGSize(width: CGFloat(dimensions.width), height: CGFloat(dimensions.height))
        
        barbellTracker.startTracking(initialRect: videoRect, in: imageSize)
        showTrackingSelector = false
    }
    
    // MARK: - Process Uploaded Video (✅ FIX API DEPRECATE)
    func processUploadedVideo(url: URL, selectionRect: CGRect, startTime: CMTime = .zero, endTime: CMTime = .positiveInfinity) {
        isProcessingVideo = true
        processingProgress = 0.0
        barbellTracker.reset()
        
        let asset = AVAsset(url: url)
        
        Task {
            do {
                // ✅ FIX: Use loadTracks instead of tracks(withMediaType:)
                let tracks = try await asset.loadTracks(withMediaType: .video)
                guard let videoTrack = tracks.first else {
                    await MainActor.run {
                        self.isProcessingVideo = false
                    }
                    return
                }
                
                // ✅ FIX: Use load(.naturalSize) instead of naturalSize
                let naturalSize = try await videoTrack.load(.naturalSize)
                
                // ✅ FIX: Use load(.duration) instead of duration
                let assetDuration = try await asset.load(.duration)
                
                await MainActor.run {
                    self.barbellTracker.startTracking(initialRect: selectionRect, in: naturalSize)
                }
                
                let actualEndTime = endTime == .positiveInfinity ? assetDuration : endTime
                let timeRange = CMTimeRange(start: startTime, end: actualEndTime)
                
                guard let reader = try? AVAssetReader(asset: asset) else {
                    await MainActor.run {
                        self.isProcessingVideo = false
                    }
                    return
                }
                
                reader.timeRange = timeRange
                
                let readerOutput = AVAssetReaderTrackOutput(
                    track: videoTrack,
                    outputSettings: [
                        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
                    ]
                )
                
                reader.add(readerOutput)
                reader.startReading()
                
                var frameCount = 0
                let duration = CMTimeGetSeconds(CMTimeSubtract(actualEndTime, startTime))
                let totalFrames = Int(duration * 30)
                
                while let sampleBuffer = readerOutput.copyNextSampleBuffer() {
                    if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds
                        
                        await MainActor.run {
                            self.barbellTracker.trackFrame(pixelBuffer, timestamp: timestamp)
                            self.processingProgress = Double(frameCount) / Double(max(totalFrames, 1))
                        }
                        
                        frameCount += 1
                    }
                }
                
                await MainActor.run {
                    self.isProcessingVideo = false
                    self.processingProgress = 1.0
                    self.recordedVideoURL = url
                }
                
            } catch {
                print("Error processing video: \(error)")
                await MainActor.run {
                    self.isProcessingVideo = false
                }
            }
        }
    }
    
    // MARK: - Cleanup
    func cleanup() {
        captureSession?.stopRunning()
        barbellTracker.reset()
    }
}

// MARK: - Video Data Delegate
extension CameraViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard barbellTracker.isTracking,
              let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds
        barbellTracker.trackFrame(pixelBuffer, timestamp: timestamp)
    }
}

// MARK: - File Output Delegate
extension CameraViewModel: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        DispatchQueue.main.async {
            self.isRecording = false
            
            if let error = error {
                print("Recording error: \(error)")
                return
            }
            
            self.recordedVideoURL = outputFileURL
            print("Video saved: \(outputFileURL)")
        }
    }
}
