//
//  ARImageTrackingViewController.swift
//  CameraApp
//
//  AR view controller with image tracking capabilities
//

import UIKit
import ARKit
import SceneKit

class ARImageTrackingViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let arSceneView: ARSCNView = {
        let view = ARSCNView()
        view.autoenablesDefaultLighting = true
        view.automaticallyUpdatesLighting = true
        return view
    }()
    
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Point camera at a marker image"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
    
    private let generateMarkersButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Generate Markers", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Properties
    
    private let session = ARSession()
    private var trackedImages: [String: SCNNode] = [:]
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupAR()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startARSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.pause()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .black
        
        arSceneView.frame = view.bounds
        arSceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        arSceneView.session = session
        arSceneView.delegate = self
        view.addSubview(arSceneView)
        
        view.addSubview(instructionLabel)
        view.addSubview(closeButton)
        view.addSubview(generateMarkersButton)
        
        setupConstraints()
        setupActions()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            instructionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            instructionLabel.heightAnchor.constraint(equalToConstant: 40),
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            
            generateMarkersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            generateMarkersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            generateMarkersButton.widthAnchor.constraint(equalToConstant: 200),
            generateMarkersButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        generateMarkersButton.addTarget(self, action: #selector(generateMarkersButtonTapped), for: .touchUpInside)
    }
    
    private func setupAR() {
        arSceneView.autoenablesDefaultLighting = true
        arSceneView.automaticallyUpdatesLighting = true
    }
    
    private func startARSession() {
        let configuration = ARWorldTrackingConfiguration()
        
        // Create reference images for tracking
        if let referenceImages = createReferenceImages() {
            configuration.detectionImages = referenceImages
            configuration.maximumNumberOfTrackedImages = 3
        }
        
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    private func createReferenceImages() -> Set<ARReferenceImage>? {
        var referenceImages = Set<ARReferenceImage>()
        
        // Create test images programmatically
        let testImages = [
            ("Marker1", createMarkerImage(text: "1", color: .systemBlue)),
            ("Marker2", createMarkerImage(text: "2", color: .systemGreen)),
            ("Marker3", createMarkerImage(text: "3", color: .systemRed))
        ]
        
        for (name, image) in testImages {
            if let cgImage = image.cgImage {
                let referenceImage = ARReferenceImage(cgImage, orientation: .up, physicalWidth: 0.1) // 10cm wide
                referenceImage.name = name
                referenceImages.insert(referenceImage)
            }
        }
        
        return referenceImages.isEmpty ? nil : referenceImages
    }
    
    private func createMarkerImage(text: String, color: UIColor) -> UIImage {
        let size = CGSize(width: 512, height: 512)
        
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            // Background
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Border
            UIColor.white.setStroke()
            let borderRect = CGRect(x: 20, y: 20, width: size.width - 40, height: size.height - 40)
            context.cgContext.setLineWidth(10)
            context.stroke(borderRect)
            
            // Text
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 300, weight: .bold),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]
            
            let textRect = CGRect(x: 0, y: size.height/2 - 150, width: size.width, height: 300)
            text.draw(in: textRect, withAttributes: attributes)
            
            // Add some unique patterns for better tracking (white: the fill colour was still the background colour)
            UIColor.white.setFill()
            let patternSize: CGFloat = 50
            for i in 0..<4 {
                for j in 0..<4 {
                    if (i + j) % 2 == 0 {
                        let x = 30 + CGFloat(i) * 120
                        let y = 30 + CGFloat(j) * 120
                        let rect = CGRect(x: x, y: y, width: patternSize, height: patternSize)
                        context.fill(rect)
                    }
                }
            }
        }
        
        return image
    }
    
    // MARK: - Actions
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func generateMarkersButtonTapped() {
        let markerVC = MarkerGeneratorViewController()
        markerVC.modalPresentationStyle = .pageSheet
        present(markerVC, animated: true)
    }
    
    private func createContentForImage(named name: String) -> SCNNode {
        let node = SCNNode()
        
        switch name {
        case "Marker1":
            // Spinning cube
            let cube = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0.005)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.systemBlue
            cube.materials = [material]
            
            let cubeNode = SCNNode(geometry: cube)
            cubeNode.position = SCNVector3(0, 0.025, 0)
            
            // Add rotation animation
            let rotation = SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 3)
            let repeatRotation = SCNAction.repeatForever(rotation)
            cubeNode.runAction(repeatRotation)
            
            node.addChildNode(cubeNode)
            
        case "Marker2":
            // Pyramid
            let pyramid = SCNPyramid(width: 0.08, height: 0.1, length: 0.08)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.systemGreen
            pyramid.materials = [material]
            
            let pyramidNode = SCNNode(geometry: pyramid)
            pyramidNode.position = SCNVector3(0, 0.05, 0)
            node.addChildNode(pyramidNode)
            
        case "Marker3":
            // Multiple spheres
            for i in 0..<3 {
                let sphere = SCNSphere(radius: 0.02)
                let material = SCNMaterial()
                material.diffuse.contents = UIColor.systemRed
                sphere.materials = [material]
                
                let sphereNode = SCNNode(geometry: sphere)
                let angle = CGFloat(i) * CGFloat.pi * 2 / 3
                sphereNode.position = SCNVector3(
                    cos(angle) * 0.04,
                    0.02,
                    sin(angle) * 0.04
                )
                
                // Add bounce animation
                let moveUp = SCNAction.moveBy(x: 0, y: 0.03, z: 0, duration: 0.5)
                let moveDown = SCNAction.moveBy(x: 0, y: -0.03, z: 0, duration: 0.5)
                let sequence = SCNAction.sequence([moveUp, moveDown])
                let repeatBounce = SCNAction.repeatForever(sequence)
                sphereNode.runAction(repeatBounce)
                
                node.addChildNode(sphereNode)
            }
            
        default:
            // Default: text label
            let text = SCNText(string: "AR", extrusionDepth: 2)
            text.font = UIFont.systemFont(ofSize: 20, weight: .bold)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.white
            text.materials = [material]
            
            let textNode = SCNNode(geometry: text)
            textNode.scale = SCNVector3(0.002, 0.002, 0.002)
            textNode.position = SCNVector3(-0.02, 0.01, 0)
            node.addChildNode(textNode)
        }
        
        return node
    }
}

// MARK: - ARSCNViewDelegate

extension ARImageTrackingViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        
        let imageName = imageAnchor.referenceImage.name ?? "Unknown"
        
        // Create content for this image
        let content = createContentForImage(named: imageName)
        node.addChildNode(content)
        
        trackedImages[imageName] = node
        
        // Update UI
        DispatchQueue.main.async {
            self.instructionLabel.text = "Detected: \(imageName)"
            self.instructionLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.7)
        }
        
        // Reset label after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.instructionLabel.text = "Point camera at a marker image"
            self.instructionLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        
        // Update tracking status
        if imageAnchor.isTracked {
            node.isHidden = false
        } else {
            node.isHidden = true
        }
    }
}

// MARK: - Marker Generator View Controller

class MarkerGeneratorViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        title = "AR Markers"
        
        // Add close button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissView)
        )
        
        setupUI()
        generateMarkers()
    }
    
    private func setupUI() {
        scrollView.frame = view.bounds
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(scrollView)
        
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }
    
    private func generateMarkers() {
        let instructions = UILabel()
        instructions.text = "Save these markers and print them or display on another screen. Point your camera at them to see AR content!"
        instructions.numberOfLines = 0
        instructions.textAlignment = .center
        instructions.font = UIFont.systemFont(ofSize: 14)
        stackView.addArrangedSubview(instructions)
        
        let markers = [
            ("Marker 1 - Blue Cube", createMarkerImage(text: "1", color: .systemBlue)),
            ("Marker 2 - Green Pyramid", createMarkerImage(text: "2", color: .systemGreen)),
            ("Marker 3 - Red Spheres", createMarkerImage(text: "3", color: .systemRed))
        ]
        
        for (name, image) in markers {
            let label = UILabel()
            label.text = name
            label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            label.textAlignment = .center
            stackView.addArrangedSubview(label)
            
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.layer.borderWidth = 2
            imageView.layer.borderColor = UIColor.separator.cgColor
            imageView.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(imageView)
            
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 300),
                imageView.heightAnchor.constraint(equalToConstant: 300)
            ])
            
            let saveButton = UIButton(type: .system)
            saveButton.setTitle("Save \(name)", for: .normal)
            saveButton.backgroundColor = .systemBlue
            saveButton.setTitleColor(.white, for: .normal)
            saveButton.layer.cornerRadius = 8
            saveButton.tag = markers.firstIndex(where: { $0.0 == name }) ?? 0
            saveButton.addTarget(self, action: #selector(saveMarker(_:)), for: .touchUpInside)
            saveButton.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(saveButton)
            
            NSLayoutConstraint.activate([
                saveButton.widthAnchor.constraint(equalToConstant: 200),
                saveButton.heightAnchor.constraint(equalToConstant: 44)
            ])
        }
    }
    
    private func createMarkerImage(text: String, color: UIColor) -> UIImage {
        let size = CGSize(width: 512, height: 512)
        
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            UIColor.white.setStroke()
            let borderRect = CGRect(x: 20, y: 20, width: size.width - 40, height: size.height - 40)
            context.cgContext.setLineWidth(10)
            context.stroke(borderRect)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 300, weight: .bold),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]
            
            let textRect = CGRect(x: 0, y: size.height/2 - 150, width: size.width, height: 300)
            text.draw(in: textRect, withAttributes: attributes)
            
            UIColor.white.setFill()
            let patternSize: CGFloat = 50
            for i in 0..<4 {
                for j in 0..<4 {
                    if (i + j) % 2 == 0 {
                        let x = 30 + CGFloat(i) * 120
                        let y = 30 + CGFloat(j) * 120
                        let rect = CGRect(x: x, y: y, width: patternSize, height: patternSize)
                        context.fill(rect)
                    }
                }
            }
        }
        
        return image
    }
    
    @objc private func saveMarker(_ sender: UIButton) {
        let markers = [
            createMarkerImage(text: "1", color: .systemBlue),
            createMarkerImage(text: "2", color: .systemGreen),
            createMarkerImage(text: "3", color: .systemRed)
        ]
        
        let image = markers[sender.tag]
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func imageSaved(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        let alert: UIAlertController
        
        if let error = error {
            alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: "Saved!", message: "Marker saved to Photos", preferredStyle: .alert)
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func dismissView() {
        dismiss(animated: true)
    }
}
