// Marker lab: the three image-tracking markers drawn by the JS port of createMarkerImage, next to the same function's
// output rendered by the real Swift code on a Mac, plus what the app anchors to each marker and the placeable objects.
import { route, app, esc, list, download } from './core.js';
import * as M from './marker_engine.js';
import { cite, resolveCites } from './cite.js';

route('demo', async () => {
  app().innerHTML = `<p class="kicker">Interactive port</p><h1>Marker lab</h1>
  <p class="lead">The AR image-tracking mode does not ship marker images: it draws three 512 × 512 pt markers in code,
  registers them with ARKit as 10 cm wide reference images and shows the same drawings for you to save and print.
  Here that drawing code runs as JavaScript, beside the Swift function's own output.</p>
  <div class="markers">${list(M.MARKERS, (m, i) => `<div class="panel mk">
    <h3>${esc(m.title)}</h3>
    <div class="pair">
      <figure><img src="static/img/marker${m.text}_swift.png" alt="${esc(m.title)} as drawn by the app's Swift code" width="512" height="512">
        <figcaption>Swift <code>createMarkerImage</code>, rendered on a Mac (Mac Catalyst)</figcaption></figure>
      <figure><canvas width="512" height="512" data-i="${i}" role="img" aria-label="${esc(m.title)} drawn by the JavaScript port"></canvas>
        <figcaption>JavaScript port, drawn in your browser</figcaption></figure>
    </div>
    <p class="small"><b>AR content:</b> ${esc(m.content)}.</p>
    <button class="alt" data-dl="${i}" type="button">Download PNG (print 10 cm wide)</button>
  </div>`)}</div>
  <div class="two">
    <div class="panel"><h3>What the code draws</h3>
      <ol class="small">
        <li>Fill 512 × 512 with the marker colour (UIKit <code>systemBlue</code>, <code>systemGreen</code>, <code>systemRed</code>).</li>
        <li>A white frame on the rect 20 … 492 with line width 10; UIKit frames inside the rect, so it covers 20 … 30 pt.</li>
        <li>The digit in 300 pt bold system font, centred in a 300 pt tall box (${cite('ARImageTrackingViewController.swift', 'let textRect = CGRect(x: 0, y: size.height/2 - 150')}).</li>
        <li>Eight 50 pt squares on a 120 pt checkerboard, (i + j) even, "for better tracking"
        (${cite('ARImageTrackingViewController.swift', 'if (i + j) % 2 == 0')}).</li>
      </ol>
      <p class="callout small">Until 2026-11-13 step 4 used the marker colour (the fill colour set in step 1), so the
      squares were invisible except for a notch cut out of the digit. They are now white in both copies of the
      function. Markers printed before that fix no longer match: print them again.</p>
      <p class="small mute">The digit's shape depends on the font (San Francisco in the app, your system font here),
      so the node test compares every sample outside the digit: 8,175 of them match the Swift render exactly.</p>
    </div>
    <div class="panel"><h3>Tracking set-up</h3>
      <ul class="small">
        <li>Reference images: physical width ${M.PHYSICAL_WIDTH_M * 100} cm, orientation up
        (${cite('ARImageTrackingViewController.swift', 'physicalWidth: 0.1')}).</li>
        <li>Up to ${M.MAX_TRACKED} images tracked at once, inside an <code>ARWorldTrackingConfiguration</code>
        (${cite('ARImageTrackingViewController.swift', 'configuration.maximumNumberOfTrackedImages = 3')}).</li>
        <li>Content is hidden while ARKit reports the image as not tracked.</li>
      </ul>
      <h3>Objects in placement mode</h3>
      <table class="small"><tbody>${list(M.OBJECT_TYPES, ([n, g]) => `<tr><td>${n}</td><td>${g}</td></tr>`)}</tbody></table>
      <p class="small mute">Random bright colour, dynamic physics body, mass 1 kg, restitution 0.5
      (${cite('ARViewController.swift', 'node.physicsBody?.restitution = 0.5')}).</p>
    </div>
  </div>`;
  app().querySelectorAll('canvas[data-i]').forEach(cv => M.drawMarker(cv.getContext('2d'), M.MARKERS[+cv.dataset.i], 1));
  app().querySelectorAll('button[data-dl]').forEach(b => b.addEventListener('click', () => {
    const m = M.MARKERS[+b.dataset.dl], cv = document.createElement('canvas');
    cv.width = cv.height = 1024;
    M.drawMarker(cv.getContext('2d'), m, 2);
    cv.toBlob(blob => download(`${m.name}.png`, blob), 'image/png');
  }));
  await resolveCites(app());
});
