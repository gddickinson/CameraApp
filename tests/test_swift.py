"""Checks on the iOS app's Swift code that can run on a Mac with Xcode (skipped elsewhere, e.g. on Linux CI).

- the whole app type-checks against the iOS SDK at its deployment target (catches build breaks);
- regression test for the AR marker drawing, run on the real Swift function (Mac Catalyst, scripts/swift_ref.py);
- the two copies of createMarkerImage (tracking reference images and the printable markers) stay identical;
- tests/fixtures/swift_reference.json (used by the JS port's node test) is still what the Swift code produces.

Run: python -m pytest -q tests/test_swift.py
"""
import json
import os
import re
import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "scripts"))
import swift_ref  # noqa: E402

IOS_TARGET = "16.0"  # lowest deployment target the code compiles for (ARPlaneAnchor.planeExtent)
needs_mac = pytest.mark.skipif(not swift_ref.available("macosx"), reason="needs macOS with Xcode")
needs_ios = pytest.mark.skipif(not swift_ref.available("iphoneos"), reason="needs Xcode with the iOS SDK")


@pytest.fixture(scope="module")
def swift_out():
    import make_swift_fixture
    return make_swift_fixture.generate()


def _px(marker, x, y):
    """Sampled colour (hex) nearest to point (x, y) in the 8-pt sample grid."""
    step = 8
    i = int(x) // step
    return marker["rows"][int(y) // step][6 * i:6 * i + 6]


@needs_ios
def test_app_typechecks_for_ios():
    errors = swift_ref.typecheck_ios(sorted(ROOT.glob("*.swift")), IOS_TARGET)
    assert errors == [], "\n".join(errors)


@needs_mac
def test_marker_tracking_pattern_is_visible(swift_out):
    """The 'unique patterns for better tracking' squares must differ from the background (they were drawn in it)."""
    for m in swift_out["markers"]:
        bg = _px(m, 100, 460)                      # plain background, inside the border
        assert _px(m, 25, 25) == "ffffff"          # white border (drawn inside the rect, 20-30 pt)
        for x, y in [(55, 55), (175, 175), (55, 295), (415, 415)]:  # centres of squares (i, j) with i + j even
            assert _px(m, x, y) != bg, f"marker {m['text']}: pattern square at {x},{y} has the background colour"
        assert _px(m, 55, 175) == bg               # (0, 1): no square


def _strip(code: str) -> str:
    code = re.sub(r"//[^\n]*", "", code)
    return "\n".join(ln.strip() for ln in code.splitlines() if ln.strip())


def test_both_marker_drawings_are_identical():
    """Printed markers (MarkerGeneratorViewController) must match the images ARKit tracks (createReferenceImages)."""
    src = ROOT / "ARImageTrackingViewController.swift"
    a = swift_ref.extract(src, r"private func createMarkerImage", nth=0)
    b = swift_ref.extract(src, r"private func createMarkerImage", nth=1)
    assert _strip(a) == _strip(b)


@needs_mac
@pytest.mark.skipif(bool(os.environ.get("CI")), reason="fixture is regenerated on George's Mac only")
def test_fixture_is_current(swift_out):
    fixture = json.loads((ROOT / "tests" / "fixtures" / "swift_reference.json").read_text())
    assert fixture["step"] == swift_out["step"]
    for got, ref in zip(swift_out["markers"], fixture["markers"]):
        # anti-aliased glyph edges may differ by a few pixels between macOS versions: compare per row, allow 2%
        cells = lambda rows: [r[i:i + 6] for r in rows for i in range(0, len(r), 6)]  # noqa: E731
        diff = sum(a != b for a, b in zip(cells(got["rows"]), cells(ref["rows"])))
        assert diff <= 0.02 * 64 * 64, f"marker {got['text']}: {diff} samples changed; run scripts/make_swift_fixture.py"
