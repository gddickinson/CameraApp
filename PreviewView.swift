//
//  PreviewView.swift
//  CameraApp
//
//  Custom UIView for displaying camera preview
//

import UIKit
import AVFoundation

class PreviewView: UIView {
    
    // Override the layer class to use AVCaptureVideoPreviewLayer
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    /// Convenience accessor for the layer as AVCaptureVideoPreviewLayer
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    /// The capture session being previewed
    var session: AVCaptureSession? {
        get {
            return videoPreviewLayer.session
        }
        set {
            videoPreviewLayer.session = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // Configure the preview layer
        videoPreviewLayer.videoGravity = .resizeAspectFill
        backgroundColor = .black
    }
}
