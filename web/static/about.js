// About: what the app is, what you need to build and run it (from the README, Info.plist and the code), this site.
import { route, app, api, esc, list } from './core.js';
import { cite as c, resolveCites } from './cite.js';

route('about', async () => {
  const info = await api('/info');
  app().innerHTML = `<p class="kicker">About</p><h1>${esc(info.title)}</h1>
  <p class="lead">${esc(info.description)}</p>
  <div class="two">
    <div class="panel"><h3>To run the real app</h3>
      <ul>
        <li>An iPhone (camera mode needs a camera; the Simulator has none). AR modes need an ARKit device; the menu
        disables them otherwise.</li>
        <li><b>iOS 16.0 or later</b>: the code uses <code>ARPlaneAnchor.planeExtent</code>
        (${c('ARViewController.swift', 'planeAnchor.planeExtent.width')}). The whole app type-checks against the iOS SDK
        at that target (tests/test_swift.py).</li>
        <li>Xcode 14 or later and an Apple developer account for signing.</li>
        <li>Camera and photo-library permission (usage strings in Info.plist).</li>
      </ul>
      <h3>Build in Xcode</h3>
      <ol>
        <li>Create a new iOS App project (interface Storyboard, language Swift). The app builds its UI in code:
        <code>AppDelegate</code> creates the window, so remove the scene manifest / main storyboard entries.</li>
        <li>Add the ${info.swift_files} <code>.swift</code> files from the repository root.</li>
        <li>Use the repository's Info.plist or add <code>NSCameraUsageDescription</code> and
        <code>NSPhotoLibraryAddUsageDescription</code>.</li>
        <li>Select your team, connect an iPhone and run; choose a mode from the menu.</li>
      </ol>
    </div>
    <div class="panel"><h3>This site</h3>
      <p>A showcase and code explorer built only from the repository: the file list, line counts, summaries and
      outlines are read from the source by the web app (<code>web/repo_index.py</code>). The
      <a href="#/demo">Marker lab</a> runs the marker drawing ported to JavaScript; a node test compares it with the
      original Swift function, which <code>scripts/make_swift_fixture.py</code> copies out of the source and renders on a
      Mac as a Mac Catalyst program.</p>
      <h3>Run the web app locally</h3>
      <pre>pip install -r requirements-web.txt
python run_web.py        # http://127.0.0.1:8265</pre>
      <h3>Tests</h3>
      <pre>python -m pytest -q tests          # web + Swift checks (Swift ones need Xcode)
node web/static/marker_engine.test.mjs</pre>
    </div>
  </div>
  <h2>Frameworks</h2>
  <p>${list(info.frameworks, f => `<span class="tag c">${esc(f)}</span>`)}</p>
  <h2>Credits and licence</h2>
  <p>CameraApp by George Dickinson, MIT License (<a href="#/code/LICENSE">LICENSE</a>). The README credits Apple's
  AVFoundation and ARKit best practices and links Apple's documentation and AVCam sample.</p>`;
  await resolveCites(app());
});
