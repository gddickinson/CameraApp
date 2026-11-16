// How it works: the app's three modes and their data flow, written from the Swift source; every claim links to its line.
import { route, app } from './core.js';
import { cite as c, resolveCites } from './cite.js';

const DIAGRAM = `<svg class="diagram" viewBox="0 0 760 400" role="img" aria-labelledby="dgt dgd">
<title id="dgt">CameraApp structure</title>
<desc id="dgd">AppDelegate shows the mode menu, which presents the camera, AR placement or image tracking screen.</desc>
<defs><marker id="ar" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" class="dg-arrow"/></marker></defs>
<g class="dg-box s"><rect x="10" y="20" width="170" height="54" rx="6"/><text x="95" y="43">AppDelegate</text><text x="95" y="61" class="dg-sub">UIWindow, no storyboard</text></g>
<g class="dg-box a"><rect x="10" y="150" width="170" height="80" rx="6"/><text x="95" y="174">ModeSelection</text><text x="95" y="192" class="dg-sub">ViewController</text><text x="95" y="212" class="dg-sub">AR supported? enables modes</text></g>
<g class="dg-box b"><rect x="250" y="20" width="230" height="110" rx="6"/><text x="365" y="43">CameraViewController</text><text x="365" y="65" class="dg-sub">permission, tap-to-focus, capture,</text><text x="365" y="83" class="dg-sub">switch camera, save to Photos</text><text x="365" y="109" class="dg-sub">PreviewView (preview layer)</text></g>
<g class="dg-box s"><rect x="560" y="20" width="190" height="110" rx="6"/><text x="655" y="43">CameraManager</text><text x="655" y="65" class="dg-sub">AVCaptureSession (.photo)</text><text x="655" y="83" class="dg-sub">wide-angle camera input</text><text x="655" y="101" class="dg-sub">photo + video-data outputs</text><text x="655" y="119" class="dg-sub">serial session queue</text></g>
<g class="dg-box c"><rect x="250" y="160" width="230" height="100" rx="6"/><text x="365" y="183">ARViewController</text><text x="365" y="205" class="dg-sub">world tracking, planes h + v</text><text x="365" y="223" class="dg-sub">tap: raycast → place object</text><text x="365" y="241" class="dg-sub">long press: hit test → remove</text></g>
<g class="dg-box c"><rect x="250" y="290" width="230" height="100" rx="6"/><text x="365" y="313">ARImageTracking</text><text x="365" y="331" class="dg-sub">ViewController</text><text x="365" y="353" class="dg-sub">3 drawn markers, 10 cm wide</text><text x="365" y="371" class="dg-sub">content per anchor name</text></g>
<g class="dg-box s"><rect x="560" y="160" width="190" height="100" rx="6"/><text x="655" y="183">ARSCNView + ARSession</text><text x="655" y="205" class="dg-sub">ARPlaneAnchor →</text><text x="655" y="223" class="dg-sub">blue SCNPlane overlay</text><text x="655" y="241" class="dg-sub">SceneKit objects + physics</text></g>
<g class="dg-box b"><rect x="560" y="290" width="190" height="100" rx="6"/><text x="655" y="313">MarkerGenerator</text><text x="655" y="331" class="dg-sub">ViewController (sheet)</text><text x="655" y="353" class="dg-sub">same drawings,</text><text x="655" y="371" class="dg-sub">save to Photos</text></g>
<g class="dg-lines"><path d="M95 74V148" marker-end="url(#ar)"/><path d="M180 175H215V75H248" marker-end="url(#ar)"/><path d="M180 195H248" marker-end="url(#ar)"/>
<path d="M180 215H215V340H248" marker-end="url(#ar)"/><path d="M480 75H558" marker-end="url(#ar)"/><path d="M480 210H558" marker-end="url(#ar)"/>
<path d="M480 340H558" marker-end="url(#ar)"/></g></svg>`;

route('how', async () => {
  app().innerHTML = `<p class="kicker">From the source</p><h1>How it works</h1>
  <p class="lead">CameraApp is a UIKit app built entirely in code (no storyboard): a menu presents one of three
  full-screen view controllers. Each statement below links to the line of Swift it comes from.</p>
  ${DIAGRAM}

  <h2>1. Start-up and the menu</h2>
  <p><code>AppDelegate</code> creates the window itself and makes <code>ModeSelectionViewController</code> the root
  (${c('AppDelegate.swift', 'window?.rootViewController = modeSelectionVC')}). The menu checks
  <code>ARWorldTrackingConfiguration.isSupported</code> and disables both AR buttons if it is not
  (${c('ModeSelectionViewController.swift', 'if ARWorldTrackingConfiguration.isSupported {')}); each button presents its
  screen full screen (${c('ModeSelectionViewController.swift', 'cameraVC.modalPresentationStyle = .fullScreen')}).</p>

  <h2>2. Camera mode (AVFoundation)</h2>
  <p><code>CameraManager</code> owns an <code>AVCaptureSession</code> and does all configuration on a serial queue
  (${c('CameraManager.swift', 'private let sessionQueue = DispatchQueue(label: "com.cameraapp.sessionqueue")')}). Set-up uses
  the <code>.photo</code> preset, the back wide-angle camera, an <code>AVCapturePhotoOutput</code> and an
  <code>AVCaptureVideoDataOutput</code> whose frames go to an optional <code>frameDelegate</code> ("useful for AR
  later"; nothing sets it yet, ${c('CameraManager.swift', 'frameDelegate?.cameraManager(self, didOutput: sampleBuffer)')}).
  <code>CameraViewController</code> asks for camera permission, then connects <code>PreviewView</code>, a view whose
  backing layer is an <code>AVCaptureVideoPreviewLayer</code> with aspect-fill (${c('PreviewView.swift', 'return AVCaptureVideoPreviewLayer.self')}).</p>
  <ul>
    <li><b>Capture</b>: auto flash when supported, high-resolution capture (${c('CameraManager.swift', 'photoSettings.flashMode = .auto')});
    the photo's data becomes a <code>UIImage</code> shown with Save / Retake. Save calls
    <code>UIImageWriteToSavedPhotosAlbum</code> (${c('CameraViewController.swift', 'UIImageWriteToSavedPhotosAlbum(image, self')}).</li>
    <li><b>Tap to focus</b>: the tap is converted to a device point of interest and both focus and exposure are set there
    (${c('CameraViewController.swift', 'captureDevicePointConverted(fromLayerPoint: location)')}).</li>
    <li><b>Switch camera</b>: removes the input and adds the opposite position inside one configuration block
    (${c('CameraManager.swift', 'self.currentCameraPosition == .back ? .front : .back')}).</li>
  </ul>

  <h2>3. AR object placement (ARKit + SceneKit)</h2>
  <p><code>ARViewController</code> runs world tracking with horizontal and vertical plane detection, adding scene depth
  on devices that support it (LiDAR) (${c('ARViewController.swift', 'configuration.planeDetection = [.horizontal, .vertical]')}).
  Each new <code>ARPlaneAnchor</code> gets a translucent blue <code>SCNPlane</code> sized to its extent and rotated flat into
  the anchor's plane, resized as the anchor updates (${c('ARViewController.swift', 'plane.width = CGFloat(planeAnchor.planeExtent.width)')}).</p>
  <ul>
    <li><b>Tap</b>: a raycast against existing plane geometry places the selected shape (cube, sphere, pyramid, cylinder,
    torus, 10 cm) at the hit point with a scale-up animation (${c('ARViewController.swift', 'allowing: .existingPlaneGeometry, alignment: .any')}).</li>
    <li><b>Long press</b>: a SceneKit hit test removes a placed object with a fade (${c('ARViewController.swift', 'placedObjects.contains(firstHit.node)')}).</li>
    <li><b>Reset</b>: after a confirmation alert, removes the objects and reruns the session with reset tracking.</li>
  </ul>
  <p class="callout small">Each object gets a <code>.dynamic</code> physics body (${c('ARViewController.swift', 'SCNPhysicsBody(type: .dynamic, shape: shape)')}),
  but the plane nodes get none, so under SceneKit's default gravity the objects fall through the detected surfaces.
  Left for George to decide and test on a device (the README now says so).</p>

  <h2>4. AR image tracking</h2>
  <p>No image assets are shipped: <code>createReferenceImages</code> draws three markers in code and registers each as
  an <code>ARReferenceImage</code> 10 cm wide (${c('ARImageTrackingViewController.swift', 'ARReferenceImage(cgImage, orientation: .up, physicalWidth: 0.1)')}),
  tracked up to three at a time in a world-tracking session. When ARKit adds an <code>ARImageAnchor</code>, the anchor's
  name chooses the content: a spinning cube, a pyramid or three bouncing spheres
  (${c('ARImageTrackingViewController.swift', 'case "Marker3":')}); the node is hidden while the image is not tracked.
  "Generate Markers" opens <code>MarkerGeneratorViewController</code>, which draws the same three images with its own copy
  of the function and saves them to Photos. The <a href="#/demo">Marker lab</a> runs that drawing code.</p>

  <h2>Permissions</h2>
  <p>Info.plist has the camera and photo-library usage strings (${c('Info.plist', 'NSPhotoLibraryAddUsageDescription')}).</p>`;
  await resolveCites(app());
});
