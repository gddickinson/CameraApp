"""Render the AR markers with the app's own Swift drawing code and save pixel samples as a JSON fixture.

`createMarkerImage(text:color:)` is copied verbatim out of ARImageTrackingViewController.swift (scripts/swift_ref.py)
and run on this Mac as a Mac Catalyst program (UIKit drawing). Each 512 x 512 pt marker is drawn into an sRGB
512 x 512 bitmap and sampled every 8 pt; web/static/marker_engine.test.mjs checks the JS port against the samples and
tests/test_swift.py checks the fixture is current. With --png the three Swift renders are also written to
web/static/img/ for the demo page.

Run (macOS with Xcode): python scripts/make_swift_fixture.py [--png]
"""
import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "scripts"))
import swift_ref  # noqa: E402

FIXTURE = ROOT / "tests" / "fixtures" / "swift_reference.json"
IMG = ROOT / "web" / "static" / "img"
MARKERS = [("1", "systemBlue"), ("2", "systemGreen"), ("3", "systemRed")]  # as in createReferenceImages()
STEP = 8


def build_source(png_dir: str | None = None) -> str:
    fn = swift_ref.extract(ROOT / "ARImageTrackingViewController.swift", r"private func createMarkerImage")
    markers = ", ".join(f'("{t}", UIColor.{c}, "{c}")' for t, c in MARKERS)
    png = f'let pngDir: String? = "{png_dir}"' if png_dir else "let pngDir: String? = nil"
    return f"""
import UIKit

struct Harness {{
{fn}
}}

func pixels(_ img: UIImage) -> [UInt8] {{
    let w = 512, h = 512
    var buf = [UInt8](repeating: 0, count: w * h * 4)
    let ctx = CGContext(data: &buf, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4,
                        space: CGColorSpace(name: CGColorSpace.sRGB)!,
                        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    ctx.interpolationQuality = .high
    ctx.draw(img.cgImage!, in: CGRect(x: 0, y: 0, width: w, height: h))
    return buf
}}

{png}
var out: [String: Any] = ["step": {STEP}]
var list: [[String: Any]] = []
for (text, color, name) in [{markers}] {{
    let img = Harness().createMarkerImage(text: text, color: color)
    let px = pixels(img)
    var rows: [String] = []
    for y in stride(from: {STEP // 2}, to: 512, by: {STEP}) {{
        var row = ""
        for x in stride(from: {STEP // 2}, to: 512, by: {STEP}) {{
            let i = (y * 512 + x) * 4
            row += String(format: "%02x%02x%02x", px[i], px[i + 1], px[i + 2])
        }}
        rows.append(row)
    }}
    list.append(["text": text, "color": name, "size": [img.size.width, img.size.height], "scale": img.scale,
                 "rows": rows])
    if let d = pngDir {{ try! img.pngData()!.write(to: URL(fileURLWithPath: d + "/marker\\(text)_swift.png")) }}
}}
out["markers"] = list
let data = try! JSONSerialization.data(withJSONObject: out, options: [.sortedKeys])
print(String(data: data, encoding: .utf8)!)
"""


def generate(png_dir: Path | None = None) -> dict:
    return json.loads(swift_ref.run(build_source(str(png_dir) if png_dir else None), catalyst=True))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--png", action="store_true", help="also write web/static/img/marker*_swift.png")
    a = ap.parse_args()
    if a.png:
        IMG.mkdir(parents=True, exist_ok=True)
    data = generate(IMG if a.png else None)
    FIXTURE.parent.mkdir(parents=True, exist_ok=True)
    FIXTURE.write_text(json.dumps(data, indent=1) + "\n")
    print(f"wrote {FIXTURE.relative_to(ROOT)}: {len(data['markers'])} markers")


if __name__ == "__main__":
    main()
