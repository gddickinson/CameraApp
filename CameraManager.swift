//
//  CameraManager.swift
//  CameraApp
//
//  Manages camera session, inputs, outputs, and capture operations
//

import AVFoundation
import UIKit

class CameraManager: NSObject {
    
    // MARK: - Properties
    
    // Capture session coordinates data flow from inputs to outputs
    private let captureSession = AVCaptureSession()
    
    // Preview layer for displaying camera feed
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    // Device inputs
    private var videoDeviceInput: AVCaptureDeviceInput?
    
    // Outputs
    private let photoOutput = AVCapturePhotoOutput()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    
    // Queue for session configuration (must be serial)
    private let sessionQueue = DispatchQueue(label: "com.cameraapp.sessionqueue")
    
    // Delegate for handling captured frames (useful for AR later)
    weak var frameDelegate: CameraFrameDelegate?
    
    // Current camera position
    private(set) var currentCameraPosition: AVCaptureDevice.Position = .back
    
    // Session running state
    private(set) var isSessionRunning = false
    
    // MARK: - Initialization
    
    override init() {
        super.init()
    }
    
    // MARK: - Session Setup
    
    /// Configure and prepare the capture session
    func setupSession(completion: @escaping (Result<Void, Error>) -> Void) {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            do {
                // Begin configuration
                self.captureSession.beginConfiguration()
                
                // Set session preset for quality
                if self.captureSession.canSetSessionPreset(.photo) {
                    self.captureSession.sessionPreset = .photo
                }
                
                // Add video input
                try self.addVideoInput(position: .back)
                
                // Add photo output
                if self.captureSession.canAddOutput(self.photoOutput) {
                    self.captureSession.addOutput(self.photoOutput)
                    
                    // Configure photo output settings: enable high-resolution capture (it is off by default;
                    // the old check read the flag it was meant to set, so it never turned on)
                    self.photoOutput.isHighResolutionCaptureEnabled = true
                }
                
                // Add video data output for frame access (useful for AR)
                if self.captureSession.canAddOutput(self.videoDataOutput) {
                    self.captureSession.addOutput(self.videoDataOutput)
                    self.videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "com.cameraapp.videoqueue"))
                    
                    // Configure video orientation
                    if let connection = self.videoDataOutput.connection(with: .video) {
                        if connection.isVideoOrientationSupported {
                            connection.videoOrientation = .portrait
                        }
                    }
                }
                
                // Commit configuration
                self.captureSession.commitConfiguration()
                
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Add video input for specified camera position
    private func addVideoInput(position: AVCaptureDevice.Position) throws {
        // Find the camera device
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else {
            throw CameraError.noCameraAvailable
        }
        
        // Create input from device
        let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
        
        // Add input to session
        if captureSession.canAddInput(videoDeviceInput) {
            captureSession.addInput(videoDeviceInput)
            self.videoDeviceInput = videoDeviceInput
            self.currentCameraPosition = position
        } else {
            throw CameraError.cannotAddInput
        }
    }
    
    // MARK: - Session Control
    
    /// Start the capture session
    func startSession() {
        sessionQueue.async { [weak self] in
            guard let self = self, !self.isSessionRunning else { return }
            self.captureSession.startRunning()
            self.isSessionRunning = self.captureSession.isRunning
        }
    }
    
    /// Stop the capture session
    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self = self, self.isSessionRunning else { return }
            self.captureSession.stopRunning()
            self.isSessionRunning = self.captureSession.isRunning
        }
    }
    
    // MARK: - Preview Layer
    
    /// Create preview layer for displaying camera feed
    func createPreviewLayer() -> AVCaptureVideoPreviewLayer {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        self.previewLayer = previewLayer
        return previewLayer
    }
    
    // MARK: - Camera Switching
    
    /// Switch between front and back cameras
    func switchCamera(completion: @escaping (Result<Void, Error>) -> Void) {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            do {
                self.captureSession.beginConfiguration()
                
                // Remove current input
                if let currentInput = self.videoDeviceInput {
                    self.captureSession.removeInput(currentInput)
                }
                
                // Add new input with opposite position
                let newPosition: AVCaptureDevice.Position = self.currentCameraPosition == .back ? .front : .back
                try self.addVideoInput(position: newPosition)
                
                self.captureSession.commitConfiguration()
                
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                self.captureSession.commitConfiguration()
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Photo Capture
    
    /// Capture a photo
    func capturePhoto(completion: @escaping (Result<UIImage, Error>) -> Void) {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Create photo settings
            let photoSettings = AVCapturePhotoSettings()
            
            // Enable high resolution if available
            photoSettings.isHighResolutionPhotoEnabled = self.photoOutput.isHighResolutionCaptureEnabled
            
            // Set flash mode to auto
            if self.photoOutput.supportedFlashModes.contains(.auto) {
                photoSettings.flashMode = .auto
            }
            
            // Create capture delegate
            let captureDelegate = PhotoCaptureDelegate(completion: completion)
            
            // Capture the photo
            self.photoOutput.capturePhoto(with: photoSettings, delegate: captureDelegate)
        }
    }
    
    // MARK: - Focus and Exposure
    
    /// Set focus point
    func setFocusPoint(_ point: CGPoint) {
        guard let device = videoDeviceInput?.device else { return }
        
        sessionQueue.async {
            do {
                try device.lockForConfiguration()
                
                if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(.autoFocus) {
                    device.focusPointOfInterest = point
                    device.focusMode = .autoFocus
                }
                
                if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(.autoExpose) {
                    device.exposurePointOfInterest = point
                    device.exposureMode = .autoExpose
                }
                
                device.unlockForConfiguration()
            } catch {
                print("Error setting focus: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Pass frames to delegate (useful for AR processing later)
        frameDelegate?.cameraManager(self, didOutput: sampleBuffer)
    }
}

// MARK: - Photo Capture Delegate

private class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    
    private let completion: (Result<UIImage, Error>) -> Void
    
    init(completion: @escaping (Result<UIImage, Error>) -> Void) {
        self.completion = completion
    }
    
    nonisolated func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            completion(.failure(CameraError.cannotProcessPhoto))
            return
        }
        
        completion(.success(image))
    }
}

// MARK: - Frame Delegate Protocol

protocol CameraFrameDelegate: AnyObject {
    func cameraManager(_ manager: CameraManager, didOutput sampleBuffer: CMSampleBuffer)
}

// MARK: - Camera Errors

enum CameraError: LocalizedError {
    case noCameraAvailable
    case cannotAddInput
    case cannotAddOutput
    case cannotProcessPhoto
    
    var errorDescription: String? {
        switch self {
        case .noCameraAvailable:
            return "No camera is available on this device"
        case .cannotAddInput:
            return "Cannot add camera input to session"
        case .cannotAddOutput:
            return "Cannot add output to session"
        case .cannotProcessPhoto:
            return "Cannot process captured photo"
        }
    }
}
