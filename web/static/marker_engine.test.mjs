// Node test: the JS marker model against the app's Swift createMarkerImage rendered on a Mac (8-pt sample grid in
// tests/fixtures/swift_reference.json). Run: node web/static/marker_engine.test.mjs
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import * as M from './marker_engine.js';

const ref = JSON.parse(readFileSync(new URL('../../tests/fixtures/swift_reference.json', import.meta.url), 'utf8'));
let checked = 0, glyph = 0;
for (const r of ref.markers) {
  const m = M.MARKERS.find(k => k.text === r.text);
  assert.equal(m.colorName, r.color);
  assert.deepEqual(r.size, [M.SIZE, M.SIZE]);
  r.rows.forEach((row, yi) => {
    for (let xi = 0; xi < row.length / 6; xi++) {
      const x = ref.step / 2 + xi * ref.step, y = ref.step / 2 + yi * ref.step;
      const got = '#' + row.slice(6 * xi, 6 * xi + 6);
      const want = M.colorAt(x, y, m);
      if (want === 'edge') continue;
      if (want === 'glyph?') { glyph += got === '#ffffff'; continue; } // digit outline (system font, anti-aliased): not modelled
      assert.equal(got, want, `marker ${r.text} at ${x},${y}`);
      checked++;
    }
  });
}
// Hand-traced from createContentForImage / createReferenceImages.
const s = M.sphereLayout();
assert.ok(Math.abs(s[0].x - 0.04) < 1e-12 && Math.abs(s[1].z - 0.04 * Math.sin(2 * Math.PI / 3)) < 1e-12);
assert.equal(M.markerShapes('1').filter(x => x.kind === 'fill').length, 1 + 8);
console.log(`marker_engine: ok (${checked} samples match the Swift render exactly, ${glyph} white digit samples skipped)`);
