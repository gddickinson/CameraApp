//
//  CameraViewController.swift
//  CameraApp
//
//  Main view controller for camera interface
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let previewView = PreviewView()
    
    private let captureButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.layer.cornerRadius = 35
        button.layer.borderWidth = 5
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let switchCameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "camera.rotate"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private let imagePreviewView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let savePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let retakePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Retake", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 8
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Properties
    
    private let cameraManager = CameraManager()
    private var capturedImage: UIImage?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        checkCameraPermissions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            cameraManager.startSession()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraManager.stopSession()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // Add preview view
        previewView.frame = view.bounds
        previewView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(previewView)
        
        // Add controls
        view.addSubview(captureButton)
        view.addSubview(switchCameraButton)
        view.addSubview(closeButton)
        view.addSubview(statusLabel)
        view.addSubview(imagePreviewView)
        view.addSubview(savePhotoButton)
        view.addSubview(retakePhotoButton)
        
        setupConstraints()
        setupActions()
        
        // Add tap gesture for focus
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleFocusTap(_:)))
        previewView.addGestureRecognizer(tapGesture)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Capture button
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            captureButton.widthAnchor.constraint(equalToConstant: 70),
            captureButton.heightAnchor.constraint(equalToConstant: 70),
            
            // Switch camera button
            switchCameraButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            switchCameraButton.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor),
            switchCameraButton.widthAnchor.constraint(equalToConstant: 50),
            switchCameraButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Close button
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Status label
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            
            // Image preview
            imagePreviewView.topAnchor.constraint(equalTo: view.topAnchor),
            imagePreviewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imagePreviewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imagePreviewView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Save button
            savePhotoButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -10),
            savePhotoButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            savePhotoButton.widthAnchor.constraint(equalToConstant: 100),
            savePhotoButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Retake button
            retakePhotoButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 10),
            retakePhotoButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            retakePhotoButton.widthAnchor.constraint(equalToConstant: 100),
            retakePhotoButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    private func setupActions() {
        captureButton.addTarget(self, action: #selector(captureButtonTapped), for: .touchUpInside)
        switchCameraButton.addTarget(self, action: #selector(switchCameraButtonTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        savePhotoButton.addTarget(self, action: #selector(savePhotoButtonTapped), for: .touchUpInside)
        retakePhotoButton.addTarget(self, action: #selector(retakePhotoButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Camera Permissions
    
    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            requestCameraPermission()
        case .denied, .restricted:
            showPermissionDeniedAlert()
        @unknown default:
            break
        }
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    self?.setupCamera()
                } else {
                    self?.showPermissionDeniedAlert()
                }
            }
        }
    }
    
    private func showPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: "Camera Access Required",
            message: "Please enable camera access in Settings to use this app.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    // MARK: - Camera Setup
    
    private func setupCamera() {
        showStatus("Setting up camera...")
        
        cameraManager.setupSession { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                // Connect preview layer
                self.previewView.session = self.cameraManager.createPreviewLayer().session
                self.cameraManager.startSession()
                self.hideStatus()
                
            case .failure(let error):
                self.showStatus("Camera setup failed: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func captureButtonTapped() {
        // Animate button
        UIView.animate(withDuration: 0.1, animations: {
            self.captureButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.captureButton.transform = .identity
            }
        }
        
        showStatus("Capturing photo...")
        
        cameraManager.capturePhoto { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let image):
                self.capturedImage = image
                self.showCapturedImage(image)
                self.hideStatus()
                
            case .failure(let error):
                self.showStatus("Capture failed: \(error.localizedDescription)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.hideStatus()
                }
            }
        }
    }
    
    @objc private func switchCameraButtonTapped() {
        cameraManager.switchCamera { [weak self] result in
            switch result {
            case .success:
                print("Camera switched successfully")
            case .failure(let error):
                self?.showStatus("Failed to switch camera: \(error.localizedDescription)")
            }
        }
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func handleFocusTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: previewView)
        let pointOfInterest = previewView.videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: location)
        
        // Set focus point
        cameraManager.setFocusPoint(pointOfInterest)
        
        // Show focus indicator
        showFocusIndicator(at: location)
    }
    
    @objc private func savePhotoButtonTapped() {
        guard let image = capturedImage else { return }
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func retakePhotoButtonTapped() {
        hideCapturedImage()
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            showStatus("Error saving photo: \(error.localizedDescription)")
        } else {
            showStatus("Photo saved successfully!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.hideStatus()
                self.hideCapturedImage()
            }
        }
    }
    
    // MARK: - UI Helpers
    
    private func showCapturedImage(_ image: UIImage) {
        imagePreviewView.image = image
        
        UIView.animate(withDuration: 0.3) {
            self.imagePreviewView.isHidden = false
            self.savePhotoButton.isHidden = false
            self.retakePhotoButton.isHidden = false
            self.captureButton.isHidden = true
            self.switchCameraButton.isHidden = true
        }
    }
    
    private func hideCapturedImage() {
        UIView.animate(withDuration: 0.3) {
            self.imagePreviewView.isHidden = true
            self.savePhotoButton.isHidden = true
            self.retakePhotoButton.isHidden = true
            self.captureButton.isHidden = false
            self.switchCameraButton.isHidden = false
        }
        
        capturedImage = nil
    }
    
    private func showStatus(_ message: String) {
        statusLabel.text = message
        statusLabel.isHidden = false
    }
    
    private func hideStatus() {
        UIView.animate(withDuration: 0.3) {
            self.statusLabel.isHidden = true
        }
    }
    
    private func showFocusIndicator(at point: CGPoint) {
        let focusView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        focusView.center = point
        focusView.layer.borderColor = UIColor.yellow.cgColor
        focusView.layer.borderWidth = 2
        focusView.layer.cornerRadius = 40
        focusView.alpha = 0
        
        previewView.addSubview(focusView)
        
        UIView.animate(withDuration: 0.3, animations: {
            focusView.alpha = 1
            focusView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 0.5, options: [], animations: {
                focusView.alpha = 0
            }) { _ in
                focusView.removeFromSuperview()
            }
        }
    }
}
