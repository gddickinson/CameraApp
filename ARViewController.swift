//
//  ARViewController.swift
//  CameraApp
//
//  AR view controller with object placement and image tracking
//

import UIKit
import ARKit
import SceneKit

class ARViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let arSceneView: ARSCNView = {
        let view = ARSCNView()
        view.autoenablesDefaultLighting = true
        view.automaticallyUpdatesLighting = true
        return view
    }()
    
    private let planeDetectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Move your device to detect surfaces..."
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
    
    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.counterclockwise"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let objectSelectionView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap to place objects"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        label.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Properties
    
    private let session = ARSession()
    private var selectedObjectType: ARObjectType = .cube
    private var detectedPlanes: [ARPlaneAnchor: SCNNode] = [:]
    private var placedObjects: [SCNNode] = []
    
    // MARK: - Object Types
    
    enum ARObjectType {
        case cube
        case sphere
        case pyramid
        case cylinder
        case torus
        
        var displayName: String {
            switch self {
            case .cube: return "Cube"
            case .sphere: return "Sphere"
            case .pyramid: return "Pyramid"
            case .cylinder: return "Cylinder"
            case .torus: return "Torus"
            }
        }
        
        var icon: String {
            switch self {
            case .cube: return "cube.fill"
            case .sphere: return "circle.fill"
            case .pyramid: return "triangle.fill"
            case .cylinder: return "cylinder.fill"
            case .torus: return "circle.circle.fill"
            }
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupAR()
        setupObjectSelection()
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
        
        // Add AR scene view
        arSceneView.frame = view.bounds
        arSceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        arSceneView.session = session
        arSceneView.delegate = self
        view.addSubview(arSceneView)
        
        // Add UI elements
        view.addSubview(planeDetectionLabel)
        view.addSubview(closeButton)
        view.addSubview(resetButton)
        view.addSubview(objectSelectionView)
        view.addSubview(infoLabel)
        
        setupConstraints()
        setupActions()
        setupGestures()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Plane detection label
            planeDetectionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            planeDetectionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            planeDetectionLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            planeDetectionLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            planeDetectionLabel.heightAnchor.constraint(equalToConstant: 40),
            
            // Close button
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Reset button
            resetButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            resetButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            resetButton.widthAnchor.constraint(equalToConstant: 40),
            resetButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Object selection
            objectSelectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            objectSelectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            objectSelectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            objectSelectionView.heightAnchor.constraint(equalToConstant: 60),
            
            // Info label
            infoLabel.bottomAnchor.constraint(equalTo: objectSelectionView.topAnchor, constant: -10),
            infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoLabel.widthAnchor.constraint(equalToConstant: 200),
            infoLabel.heightAnchor.constraint(equalToConstant: 30),
        ])
    }
    
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arSceneView.addGestureRecognizer(tapGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        arSceneView.addGestureRecognizer(longPressGesture)
    }
    
    private func setupObjectSelection() {
        let objects: [ARObjectType] = [.cube, .sphere, .pyramid, .cylinder, .torus]
        
        for objectType in objects {
            let button = UIButton(type: .system)
            button.setImage(UIImage(systemName: objectType.icon), for: .normal)
            button.tintColor = .white
            button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.7)
            button.layer.cornerRadius = 8
            button.tag = objects.firstIndex(of: objectType) ?? 0
            button.addTarget(self, action: #selector(objectButtonTapped(_:)), for: .touchUpInside)
            objectSelectionView.addArrangedSubview(button)
        }
        
        // Highlight first button
        if let firstButton = objectSelectionView.arrangedSubviews.first as? UIButton {
            firstButton.backgroundColor = UIColor.systemBlue
        }
    }
    
    // MARK: - AR Session
    
    private func setupAR() {
        // Enable default lighting
        arSceneView.autoenablesDefaultLighting = true
        arSceneView.automaticallyUpdatesLighting = true
        
        // Show statistics
        arSceneView.showsStatistics = false
        
        // Enable debug options (optional)
        // arSceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin]
    }
    
    private func startARSession() {
        let configuration = ARWorldTrackingConfiguration()
        
        // Enable plane detection
        configuration.planeDetection = [.horizontal, .vertical]
        
        // Enable environment texturing
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
            configuration.frameSemantics.insert(.sceneDepth)
        }
        
        // Run session
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    private func resetARSession() {
        // Remove all placed objects
        for node in placedObjects {
            node.removeFromParentNode()
        }
        placedObjects.removeAll()
        
        // Reset session
        startARSession()
        
        // Show detection label
        planeDetectionLabel.isHidden = false
        planeDetectionLabel.text = "Move your device to detect surfaces..."
    }
    
    // MARK: - Actions
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func resetButtonTapped() {
        let alert = UIAlertController(
            title: "Reset AR Session",
            message: "This will remove all placed objects and restart tracking.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { [weak self] _ in
            self?.resetARSession()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc private func objectButtonTapped(_ sender: UIButton) {
        let objects: [ARObjectType] = [.cube, .sphere, .pyramid, .cylinder, .torus]
        selectedObjectType = objects[sender.tag]
        
        // Update button appearances
        for (index, view) in objectSelectionView.arrangedSubviews.enumerated() {
            if let button = view as? UIButton {
                button.backgroundColor = index == sender.tag ? 
                    UIColor.systemBlue : UIColor.systemBlue.withAlphaComponent(0.7)
            }
        }
        
        // Update info label
        infoLabel.text = "Tap to place \(selectedObjectType.displayName)"
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: arSceneView)
        
        // Perform raycast
        let query = arSceneView.raycastQuery(from: location, allowing: .existingPlaneGeometry, alignment: .any)
        
        if let query = query {
            let results = arSceneView.session.raycast(query)
            if let firstResult = results.first {
                placeObject(at: firstResult)
            }
        }
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        let location = gesture.location(in: arSceneView)
        let hitTestResults = arSceneView.hitTest(location, options: [:])
        
        if let firstHit = hitTestResults.first,
           placedObjects.contains(firstHit.node) {
            removeObject(firstHit.node)
        }
    }
    
    // MARK: - Object Placement
    
    private func placeObject(at result: ARRaycastResult) {
        // Create the object
        let node = createObject(type: selectedObjectType)
        
        // Set position from raycast result
        let transform = result.worldTransform
        node.position = SCNVector3(
            transform.columns.3.x,
            transform.columns.3.y,
            transform.columns.3.z
        )
        
        // Add to scene
        arSceneView.scene.rootNode.addChildNode(node)
        placedObjects.append(node)
        
        // Animate placement
        animateObjectPlacement(node)
        
        // Hide plane detection label after first placement
        if !planeDetectionLabel.isHidden {
            UIView.animate(withDuration: 0.3) {
                self.planeDetectionLabel.alpha = 0
            } completion: { _ in
                self.planeDetectionLabel.isHidden = true
            }
        }
    }
    
    private func createObject(type: ARObjectType) -> SCNNode {
        let geometry: SCNGeometry
        let size: CGFloat = 0.1
        
        switch type {
        case .cube:
            geometry = SCNBox(width: size, height: size, length: size, chamferRadius: 0.005)
        case .sphere:
            geometry = SCNSphere(radius: size / 2)
        case .pyramid:
            geometry = SCNPyramid(width: size, height: size, length: size)
        case .cylinder:
            geometry = SCNCylinder(radius: size / 2, height: size)
        case .torus:
            geometry = SCNTorus(ringRadius: size / 2, pipeRadius: size / 6)
        }
        
        // Create material with random color
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.randomBright()
        material.specular.contents = UIColor.white
        material.shininess = 0.8
        geometry.materials = [material]
        
        let node = SCNNode(geometry: geometry)
        
        // Add physics body for realism
        let shape = SCNPhysicsShape(geometry: geometry, options: nil)
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        node.physicsBody?.mass = 1.0
        node.physicsBody?.restitution = 0.5
        
        return node
    }
    
    private func removeObject(_ node: SCNNode) {
        // Animate removal
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.3
        
        node.opacity = 0
        node.scale = SCNVector3(0.1, 0.1, 0.1)
        
        SCNTransaction.completionBlock = {
            node.removeFromParentNode()
            self.placedObjects.removeAll { $0 == node }
        }
        
        SCNTransaction.commit()
    }
    
    private func animateObjectPlacement(_ node: SCNNode) {
        // Start small
        node.scale = SCNVector3(0.1, 0.1, 0.1)
        
        // Animate to normal size
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.3
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
        
        node.scale = SCNVector3(1, 1, 1)
        
        SCNTransaction.commit()
    }
}

// MARK: - ARSCNViewDelegate

extension ARViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // Create plane visualization
        let planeNode = createPlaneNode(for: planeAnchor)
        node.addChildNode(planeNode)
        
        detectedPlanes[planeAnchor] = planeNode
        
        // Update label
        DispatchQueue.main.async {
            if !self.planeDetectionLabel.isHidden {
                self.planeDetectionLabel.text = "Surface detected! Tap to place objects"
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor,
              let planeNode = detectedPlanes[planeAnchor],
              let plane = planeNode.geometry as? SCNPlane else { return }
        
        // Update plane size
        plane.width = CGFloat(planeAnchor.planeExtent.width)
        plane.height = CGFloat(planeAnchor.planeExtent.height)
        
        // Update position
        planeNode.position = SCNVector3(
            planeAnchor.center.x,
            0,
            planeAnchor.center.z
        )
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        detectedPlanes.removeValue(forKey: planeAnchor)
    }
    
    private func createPlaneNode(for planeAnchor: ARPlaneAnchor) -> SCNNode {
        let plane = SCNPlane(
            width: CGFloat(planeAnchor.planeExtent.width),
            height: CGFloat(planeAnchor.planeExtent.height)
        )
        
        // Create semi-transparent material
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.systemBlue.withAlphaComponent(0.3)
        material.isDoubleSided = true
        plane.materials = [material]
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3(
            planeAnchor.center.x,
            0,
            planeAnchor.center.z
        )
        
        // Rotate to horizontal
        planeNode.eulerAngles.x = -.pi / 2
        
        return planeNode
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.planeDetectionLabel.text = "AR Session failed: \(error.localizedDescription)"
        }
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        DispatchQueue.main.async {
            self.planeDetectionLabel.text = "AR Session interrupted"
            self.planeDetectionLabel.isHidden = false
        }
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        DispatchQueue.main.async {
            self.planeDetectionLabel.text = "Resuming AR..."
            self.resetARSession()
        }
    }
}

// MARK: - UIColor Extension

extension UIColor {
    static func randomBright() -> UIColor {
        let colors: [UIColor] = [
            .systemRed, .systemBlue, .systemGreen, .systemYellow,
            .systemOrange, .systemPink, .systemPurple, .systemTeal
        ]
        return colors.randomElement() ?? .systemBlue
    }
}
