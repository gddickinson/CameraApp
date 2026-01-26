//
//  ModeSelectionViewController.swift
//  CameraApp
//
//  Selection screen for Camera vs AR mode
//

import UIKit
import ARKit

class ModeSelectionViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "CameraApp"
        label.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose your mode"
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("📷  Camera Mode", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let arButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🎯  AR Mode", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemPurple
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let cameraDescLabel: UILabel = {
        let label = UILabel()
        label.text = "Capture photos with manual controls"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let arDescLabel: UILabel = {
        let label = UILabel()
        label.text = "Place 3D objects in the real world"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let imageTrackingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🖼  Image Tracking", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemOrange
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let imageTrackingDescLabel: UILabel = {
        let label = UILabel()
        label.text = "Detect images and display AR content"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let arStatusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .systemYellow
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        checkARSupport()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(cameraButton)
        view.addSubview(arButton)
        view.addSubview(imageTrackingButton)
        view.addSubview(cameraDescLabel)
        view.addSubview(arDescLabel)
        view.addSubview(imageTrackingDescLabel)
        view.addSubview(arStatusLabel)
        
        setupConstraints()
        setupActions()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Title
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Camera button
            cameraButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cameraButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
            cameraButton.widthAnchor.constraint(equalToConstant: 280),
            cameraButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Camera description
            cameraDescLabel.topAnchor.constraint(equalTo: cameraButton.bottomAnchor, constant: 8),
            cameraDescLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cameraDescLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            cameraDescLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // AR button
            arButton.topAnchor.constraint(equalTo: cameraDescLabel.bottomAnchor, constant: 30),
            arButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            arButton.widthAnchor.constraint(equalToConstant: 280),
            arButton.heightAnchor.constraint(equalToConstant: 60),
            
            // AR description
            arDescLabel.topAnchor.constraint(equalTo: arButton.bottomAnchor, constant: 8),
            arDescLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            arDescLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            arDescLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // Image tracking button
            imageTrackingButton.topAnchor.constraint(equalTo: arDescLabel.bottomAnchor, constant: 30),
            imageTrackingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageTrackingButton.widthAnchor.constraint(equalToConstant: 280),
            imageTrackingButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Image tracking description
            imageTrackingDescLabel.topAnchor.constraint(equalTo: imageTrackingButton.bottomAnchor, constant: 8),
            imageTrackingDescLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageTrackingDescLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            imageTrackingDescLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // AR status
            arStatusLabel.topAnchor.constraint(equalTo: imageTrackingDescLabel.bottomAnchor, constant: 8),
            arStatusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    private func setupActions() {
        cameraButton.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
        arButton.addTarget(self, action: #selector(arButtonTapped), for: .touchUpInside)
        imageTrackingButton.addTarget(self, action: #selector(imageTrackingButtonTapped), for: .touchUpInside)
    }
    
    private func checkARSupport() {
        if ARWorldTrackingConfiguration.isSupported {
            arStatusLabel.text = "✓ AR supported on this device"
            arStatusLabel.textColor = .systemGreen
            arButton.isEnabled = true
            imageTrackingButton.isEnabled = true
        } else {
            arStatusLabel.text = "⚠ AR not supported on this device"
            arStatusLabel.textColor = .systemRed
            arButton.isEnabled = false
            imageTrackingButton.isEnabled = false
            arButton.alpha = 0.5
            imageTrackingButton.alpha = 0.5
        }
    }
    
    // MARK: - Actions
    
    @objc private func cameraButtonTapped() {
        animateButton(cameraButton)
        
        let cameraVC = CameraViewController()
        cameraVC.modalPresentationStyle = .fullScreen
        present(cameraVC, animated: true)
    }
    
    @objc private func arButtonTapped() {
        animateButton(arButton)
        
        let arVC = ARViewController()
        arVC.modalPresentationStyle = .fullScreen
        present(arVC, animated: true)
    }
    
    @objc private func imageTrackingButtonTapped() {
        animateButton(imageTrackingButton)
        
        let imageTrackingVC = ARImageTrackingViewController()
        imageTrackingVC.modalPresentationStyle = .fullScreen
        present(imageTrackingVC, animated: true)
    }
    
    private func animateButton(_ button: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                button.transform = .identity
            }
        }
    }
}
