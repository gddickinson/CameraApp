# CameraApp

iOS UIKit/AVFoundation/ARKit app (Swift files at the repo root) with a web showcase in `web/`.
@INTERFACE.md

- Web tests: `python -m pytest -q tests` and `node web/static/*.test.mjs`. Swift checks need macOS + Xcode.
- After changing `createMarkerImage`, change both copies, run `python scripts/make_swift_fixture.py --png` and
  update `web/static/marker_engine.js`.
