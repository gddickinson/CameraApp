// AR marker drawing ported from createMarkerImage(text:color:) in ARImageTrackingViewController.swift (no DOM).
// markerShapes() lists what the Swift code draws, in order; drawMarker() paints it on a canvas; colorAt() predicts a
// pixel's colour for marker_engine.test.mjs, which compares it with the Swift function rendered on a Mac
// (tests/fixtures/swift_reference.json, scripts/make_swift_fixture.py).

export const SIZE = 512;                       // CGSize(width: 512, height: 512), in points
export const PHYSICAL_WIDTH_M = 0.1;           // ARReferenceImage(..., physicalWidth: 0.1)
export const MAX_TRACKED = 3;                  // configuration.maximumNumberOfTrackedImages = 3

// The three markers (createReferenceImages / MarkerGeneratorViewController). Colours are UIKit's systemBlue /
// systemGreen / systemRed as rendered on this Mac in light mode (sRGB, read from the Swift render).
export const MARKERS = [
  { name: 'Marker1', title: 'Marker 1 - Blue Cube', text: '1', colorName: 'systemBlue', color: '#0088ff',
    content: 'Spinning blue cube, 5 cm, one turn every 3 s' },
  { name: 'Marker2', title: 'Marker 2 - Green Pyramid', text: '2', colorName: 'systemGreen', color: '#34c759',
    content: 'Green pyramid, 8 x 10 x 8 cm' },
  { name: 'Marker3', title: 'Marker 3 - Red Spheres', text: '3', colorName: 'systemRed', color: '#ff383c',
    content: 'Three red 2 cm spheres on a 4 cm circle, bouncing 3 cm every second' },
];

// Draw order of the Swift function (after the 2026-11-13 fix the squares are white).
export function markerShapes(text) {
  const shapes = [{ kind: 'fill', rect: [0, 0, SIZE, SIZE], color: 'marker' }];
  // context.stroke(borderRect) with line width 10: UIKit frames *inside* the rect, so the border covers 20...30 pt.
  shapes.push({ kind: 'frame', rect: [20, 20, SIZE - 40, SIZE - 40], width: 10, color: 'white' });
  shapes.push({ kind: 'text', text, rect: [0, SIZE / 2 - 150, SIZE, 300], size: 300, color: 'white' });
  for (let i = 0; i < 4; i++) for (let j = 0; j < 4; j++) {
    if ((i + j) % 2 === 0) shapes.push({ kind: 'fill', rect: [30 + i * 120, 30 + j * 120, 50, 50], color: 'white' });
  }
  return shapes;
}

const inside = (x, y, [rx, ry, rw, rh], m = 0) => x >= rx + m && x < rx + rw - m && y >= ry + m && y < ry + rh - m;
const near = (x, y, [rx, ry, rw, rh], m) => inside(x, y, [rx - m, ry - m, rw + 2 * m, rh + 2 * m]) && !inside(x, y, [rx, ry, rw, rh], m);

// Predicted colour at point (x, y): '#rrggbb', 'edge' within 2 pt of a shape edge (anti-aliasing), or 'glyph?' where
// the digit may be (its outline depends on the system font, so it is not modelled).
export function colorAt(x, y, marker) {
  let c = marker.color;
  for (const s of markerShapes(marker.text)) {
    const col = s.color === 'white' ? '#ffffff' : marker.color;
    if (s.kind === 'fill') {
      if (near(x, y, s.rect, 2)) return 'edge';
      if (inside(x, y, s.rect)) c = col;
    } else if (s.kind === 'frame') {
      const outer = s.rect, inner = [outer[0] + s.width, outer[1] + s.width, outer[2] - 2 * s.width, outer[3] - 2 * s.width];
      if (near(x, y, outer, 2) || near(x, y, inner, 2)) return 'edge';
      if (inside(x, y, outer) && !inside(x, y, inner)) c = col;
    } else if (s.kind === 'text' && x > 140 && x < 372 && y > 100 && y < 412) {
      if (c !== '#ffffff') c = 'glyph?';
    }
  }
  return c;
}

// Paint a marker on a 2D canvas context at `scale` pixels per point (the app renders at the screen scale).
export function drawMarker(ctx, marker, scale = 1) {
  ctx.save(); ctx.scale(scale, scale);
  for (const s of markerShapes(marker.text)) {
    ctx.fillStyle = s.color === 'white' ? '#ffffff' : marker.color;
    if (s.kind === 'fill') ctx.fillRect(...s.rect);
    else if (s.kind === 'frame') {
      const [x, y, w, h] = s.rect, b = s.width;
      ctx.fillRect(x, y, w, b); ctx.fillRect(x, y + h - b, w, b); ctx.fillRect(x, y, b, h); ctx.fillRect(x + w - b, y, b, h);
    } else {
      // Centred in its rect like NSString.draw(in:) with .center alignment, from the top of the rect
      ctx.font = `bold ${s.size}px -apple-system, "Helvetica Neue", Arial, sans-serif`;
      ctx.textAlign = 'center'; ctx.textBaseline = 'top';
      ctx.fillText(s.text, s.rect[0] + s.rect[2] / 2, s.rect[1] + s.size * 0.08);
    }
  }
  ctx.restore();
}

// Marker 3 content: three spheres at angle i * 2pi/3 on a 4 cm circle (createContentForImage, "Marker3").
export const sphereLayout = () => [0, 1, 2].map(i => {
  const a = i * Math.PI * 2 / 3;
  return { x: Math.cos(a) * 0.04, y: 0.02, z: Math.sin(a) * 0.04 };
});

// ARViewController object types: SceneKit geometry for each, with size = 0.1 m.
export const OBJECT_TYPES = [
  ['Cube', 'SCNBox 10 x 10 x 10 cm, chamfer 0.5 cm'], ['Sphere', 'SCNSphere radius 5 cm'],
  ['Pyramid', 'SCNPyramid 10 x 10 x 10 cm'], ['Cylinder', 'SCNCylinder radius 5 cm, height 10 cm'],
  ['Torus', 'SCNTorus ring radius 5 cm, pipe radius 1.67 cm'],
];
