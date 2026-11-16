# CameraApp with AR

An iOS camera and AR application built with Swift, AVFoundation, and ARKit.

## Features

### Camera Mode
- ✅ Real-time camera preview
- ✅ Photo capture with high-resolution support
- ✅ Front/back camera switching
- ✅ Tap-to-focus functionality
- ✅ Auto flash support
- ✅ Photo saving to library
- ✅ Clean, modern UI

### AR Object Placement Mode
- ✅ Plane detection (horizontal and vertical)
- ✅ 3D object placement on detected surfaces
- ✅ Multiple object types (cube, sphere, pyramid, cylinder, torus)
- ✅ Interactive object selection
- ✅ Physics simulation
- ✅ Object removal (long press)
- ✅ Session reset functionality
- ✅ Real-time surface visualization

### AR Image Tracking Mode
- ✅ Custom marker generation
- ✅ Image detection and tracking
- ✅ AR content anchored to detected images
- ✅ Multiple marker support (up to 3 simultaneous)
- ✅ Animated 3D content
- ✅ Marker export to Photos

## Architecture

```
CameraApp/
├── Mode Selection
│   ├── ModeSelectionViewController - Main menu
│   └── Camera/AR mode selection
│
├── Camera Mode
│   ├── CameraManager - AVFoundation session management
│   ├── PreviewView - Camera preview display
│   └── CameraViewController - Camera UI and controls
│
├── AR Object Placement
│   └── ARViewController - ARKit world tracking and object placement
│
└── AR Image Tracking
    ├── ARImageTrackingViewController - Image detection and tracking
    └── MarkerGeneratorViewController - Test marker generation (in ARImageTrackingViewController.swift)
```

## Requirements

- iOS 16.0+ (the code uses `ARPlaneAnchor.planeExtent`, iOS 16)
- Xcode 14.0+
- Physical iOS device with:
  - Camera (simulator not supported for camera features)
  - ARKit support (iPhone 6s or later for AR features)
- Swift 5.0+

## Quick Start

### 1. Create Xcode Project

1. Open Xcode
2. File → New → Project
3. Choose "App" template
4. Configure:
   - Product Name: `CameraApp`
   - Interface: **Storyboard**
   - Language: **Swift**

### 2. Add Source Files

Add all `.swift` files to your project:
- `AppDelegate.swift`
- `ModeSelectionViewController.swift`
- `CameraManager.swift`
- `PreviewView.swift`
- `CameraViewController.swift`
- `ARViewController.swift`
- `ARImageTrackingViewController.swift`

### 3. Configure Info.plist

Required permissions:
```xml
<key>NSCameraUsageDescription</key>
<string>This app requires camera access to capture photos, display AR content, and track images in the real world.</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>This app needs permission to save photos and AR markers to your photo library.</string>
```

### 4. Build and Run

- Connect physical device
- Build and run (⌘R)
- Choose your mode from the main menu

## Usage Guide

### Camera Mode

1. **Capture Photo**: Tap the white circle button
2. **Switch Camera**: Tap the rotate icon
3. **Focus**: Tap anywhere on the screen
4. **Save**: After capture, tap "Save" to save to Photos
5. **Retake**: Tap "Retake" to try again

### AR Object Placement Mode

1. **Initial Setup**:
   - Hold device upright
   - Move slowly to detect surfaces
   - Look for blue transparent planes

2. **Place Objects**:
   - Select object type from bottom toolbar
   - Tap on detected surface to place
   - Objects have physics bodies (placed objects get dynamic physics bodies, but the detected planes have none, so objects currently fall through surfaces)

3. **Remove Objects**:
   - Long press on any placed object to remove it

4. **Reset Session**:
   - Tap reset button (↻) in top left
   - Confirms before clearing all objects

### AR Image Tracking Mode

1. **Generate Markers**:
   - Tap "Generate Markers" button
   - View 3 test markers (Blue #1, Green #2, Red #3)
   - Save markers to Photos
   - Print or display on another screen

2. **Track Images**:
   - Point camera at printed/displayed marker
   - Watch AR content appear anchored to the marker
   - Different content for each marker:
     - Marker 1: Spinning blue cube
     - Marker 2: Green pyramid
     - Marker 3: Red bouncing spheres

## AR Features in Detail

### Object Types

- **Cube**: Simple box with physics
- **Sphere**: Rolling ball
- **Pyramid**: Triangular pyramid
- **Cylinder**: Upright cylinder
- **Torus**: Donut shape

All objects feature:
- Random bright colors
- Realistic physics simulation
- Smooth placement animations
- Dynamic lighting

### Plane Detection

The app detects:
- **Horizontal planes**: Tables, floors, desks
- **Vertical planes**: Walls, doors

Visual indicators:
- Blue transparent overlay on detected surfaces
- Real-time updates as surfaces are tracked

### Image Tracking

Features:
- Tracks up to 3 images simultaneously
- 10cm physical width reference
- High-contrast markers for reliable tracking
- Unique patterns for robust detection

## Troubleshooting

### AR Issues

**"AR not supported on this device"**
- AR requires iPhone 6s or later
- Check Settings → General → About → Model

**Plane detection not working**
- Ensure good lighting
- Look for textured surfaces (not plain white)
- Move device slowly and steadily
- Point at surfaces at an angle

**Objects not staying in place**
- Wait for plane detection to stabilize
- Place objects on well-tracked surfaces
- Avoid moving too fast

**Image tracking not working**
- Print markers at reasonable size (10cm+ wide)
- Ensure good lighting
- Hold marker flat and steady
- Use high-quality prints (not screen photos of prints)

### Camera Issues

**Black screen**
- Check camera permissions in Settings
- Restart app
- Ensure you're on physical device

**Build errors**
- Clean build folder (⌘⇧K)
- Remove Info.plist from Copy Bundle Resources
- Check all files are added to target

## Advanced Usage

### Custom Markers

To create your own markers for image tracking:

1. Create high-contrast images (512x512 px minimum)
2. Include unique patterns for better tracking
3. Add borders or distinctive features
4. Test with various lighting conditions

Optimal marker properties:
- High contrast (dark background, light features or vice versa)
- Unique asymmetric patterns
- Clear borders
- Non-reflective surface when printed

### Performance Tips

- Limit placed objects to 20-30 for best performance
- Use simpler geometries for better framerates
- Close AR mode when not in use to save battery
- Reduce physics complexity for more objects

## Code Structure

### Camera Mode Classes

**CameraManager**
- Manages AVCaptureSession
- Handles camera input/output
- Photo capture functionality
- Frame-by-frame access

**PreviewView**
- Custom UIView with AVCaptureVideoPreviewLayer
- Handles camera preview display

**CameraViewController**
- UI management
- User interaction handling
- Permission management

### AR Mode Classes

**ARViewController**
- ARKit world tracking
- Plane detection and visualization
- 3D object creation and placement
- Physics simulation

**ARImageTrackingViewController**
- Image detection configuration
- AR content anchoring
- Marker generation and export

**ModeSelectionViewController**
- Main menu interface
- AR capability detection
- Mode navigation

## Project Files

```
CameraApp/
├── AppDelegate.swift                    # App lifecycle
├── ModeSelectionViewController.swift    # Main menu
├── CameraManager.swift                  # Camera session
├── PreviewView.swift                    # Camera preview
├── CameraViewController.swift           # Camera UI
├── ARViewController.swift               # AR object placement
├── ARImageTrackingViewController.swift  # AR image tracking
└── Info.plist                          # Permissions
```

## API Overview

### Key Frameworks

- **AVFoundation**: Camera capture and media processing
- **ARKit**: Augmented reality and world tracking
- **SceneKit**: 3D graphics rendering
- **UIKit**: User interface

### Important Classes

- `AVCaptureSession` - Camera session coordination
- `ARSession` - AR tracking and scene understanding
- `ARWorldTrackingConfiguration` - AR configuration
- `SCNNode` - 3D object representation
- `ARPlaneAnchor` - Detected surface anchor
- `ARImageAnchor` - Detected image anchor

## Best Practices

### AR Development

1. **Always test on device** - ARKit doesn't work in simulator
2. **Provide clear instructions** - Users need guidance for plane detection
3. **Handle interruptions** - Phone calls, app switching, etc.
4. **Manage resources** - AR is battery-intensive
5. **Test in various lighting** - Different environments affect tracking

### Camera Development

1. **Request permissions properly** - Clear usage descriptions
2. **Handle all states** - Authorized, denied, restricted
3. **Use background queues** - Don't block main thread
4. **Provide feedback** - Show users what's happening
5. **Test edge cases** - Device rotation, interruptions, etc.

## Resources

- [Apple ARKit Documentation](https://developer.apple.com/documentation/arkit)
- [Apple AVFoundation Documentation](https://developer.apple.com/documentation/avfoundation)
- [SceneKit Documentation](https://developer.apple.com/documentation/scenekit)
- [AVCam Sample Code](https://developer.apple.com/documentation/avfoundation/avcam-building-a-camera-app)
- [ARKit Best Practices](https://developer.apple.com/documentation/arkit/world_tracking/best_practices_for_world_tracking)

## What's Next?

Extend the app with:
- [ ] Video recording in camera mode
- [ ] ARKit face tracking
- [ ] Custom 3D model loading (.usdz, .scn)
- [ ] Multi-user AR experiences
- [ ] Object persistence across sessions
- [ ] AR measurement tools
- [ ] Occlusion support
- [ ] LiDAR integration (iPad Pro, iPhone 12 Pro+)

## License

Sample project for educational purposes.

## Credits

Built following Apple's best practices for AVFoundation and ARKit development.
