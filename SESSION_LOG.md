# Session log

## 2026-11-13/16: web showcase (branch web-interface)
- Added a web showcase + code explorer (FastAPI app on port 8265, static GitHub Pages export): home with real counts,
  code explorer (Swift highlighter, outline, search), "How it works" with an SVG diagram and source links,
  Marker lab (JS port of `createMarkerImage` beside the Swift render), About.
- The Swift function is copied verbatim from the source and run on the Mac as a Mac Catalyst program
  (scripts/make_swift_fixture.py); 8,175 pixel samples outside the digit match the JS model exactly.
- Fixed: marker tracking squares were drawn in the background colour (invisible); now white in both copies.
  Old printed markers must be reprinted. Regression test renders the real function.
- Fixed: `isHighResolutionCaptureEnabled` was only set to true if already true (never); now set. Type-check only,
  not tested on a device.
- Docs: minimum iOS 16 (planeExtent), physics caveat, MarkerGeneratorViewController location.
- For George (device needed): placed objects are dynamic physics bodies but planes have none, so they fall through
  surfaces; `PhotoCaptureDelegate` is created locally and not retained (AVCapturePhotoOutput keeps a weak reference,
  Apple's AVCam keeps them in a dictionary), so capture may never call back; its completion runs off the main
  thread and updates UIKit (CameraViewController shows the image from that callback).
