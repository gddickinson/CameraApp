# CameraApp: navigation map

An iOS (UIKit + AVFoundation + ARKit) app, plus a Python/JS web showcase. The Swift files sit at the repository root;
they are added to an Xcode project by hand (there is no .xcodeproj in the repo).

## iOS app (Swift, repo root)
| File | Contents |
|------|----------|
| AppDelegate.swift | `@main AppDelegate`: creates the window, root = ModeSelectionViewController |
| ModeSelectionViewController.swift | menu of the three modes; `checkARSupport` disables AR modes on unsupported devices |
| CameraManager.swift | `CameraManager` (AVCaptureSession on a serial queue: setupSession, start/stop, switchCamera, capturePhoto, setFocusPoint), `PhotoCaptureDelegate`, `CameraFrameDelegate`, `CameraError` |
| PreviewView.swift | `PreviewView`: UIView backed by AVCaptureVideoPreviewLayer |
| CameraViewController.swift | camera UI: permission, capture/save/retake, switch, tap-to-focus indicator |
| ARViewController.swift | AR object placement: plane detection + visualisation, raycast placement, long-press removal, reset; `UIColor.randomBright` |
| ARImageTrackingViewController.swift | image tracking: `createReferenceImages`, `createMarkerImage`, `createContentForImage`; `MarkerGeneratorViewController` (printable markers, second copy of createMarkerImage) |
| Info.plist | camera / photo-library usage strings, orientations, device capabilities |

## Web showcase (Python + plain ES modules)
| Path | Contents |
|------|----------|
| run_web.py | starts uvicorn on 127.0.0.1:8265 |
| web/app.py | FastAPI: `/api/info`, `/api/tree`, `/api/source`; `STATIC_ENDPOINTS` |
| web/repo_index.py | `app_files`, `summary`, `outline`, `tree`, `sources`, `counts` (reads the Swift files) |
| web/project.py | title, description, port, EXCLUDE (web files left out of the explorer) |
| web/static/core.js, style.css | shared kit (router, api, helpers; theme) |
| web/static/main.js, static_api.js, site.js | entry, static-site data layer, repo-specific home text |
| web/static/home.js, code.js, how.js, demo.js, about.js | pages |
| web/static/swift_highlight.js (+ .test.mjs) | Swift / plist / Markdown highlighter |
| web/static/cite.js | `cite(file, needle)` links resolved to live line numbers |
| web/static/marker_engine.js (+ .test.mjs) | JS port of `createMarkerImage` (shapes, colours, canvas drawing) and AR content constants |
| web/static/img/marker*_swift.png | the three markers rendered by the real Swift function (scripts/make_swift_fixture.py --png) |
| scripts/swift_ref.py | extract Swift declarations verbatim, compile/run them on macOS (Catalyst for UIKit), type-check for iOS |
| scripts/make_swift_fixture.py | renders the markers with the real Swift code -> tests/fixtures/swift_reference.json |
| scripts/build_static.py, screenshots.py | static site export; smoke test + README images |
| tests/test_web.py | API, static build, citations, node tests |
| tests/test_swift.py | iOS type-check, marker regression test, copies identical, fixture currency (macOS + Xcode only) |
