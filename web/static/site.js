// Repo-specific text for the shared pages (home cards, hero). Descriptions come from the README and the code.
export const SITE = {
  kicker: 'iOS · UIKit · AVFoundation · ARKit · SceneKit',
  lead: 'An iOS camera and AR application with three modes: a photo camera (AVFoundation) with tap-to-focus and ' +
    'front/back switching, AR object placement on detected planes, and AR image tracking of three markers the app ' +
    'draws itself. It is a native iPhone app; this site shows its Swift source and draws its AR markers in your browser.',
  cards: [
    ['#/code', 'Code explorer', 'Every Swift file with its header summary, outline and search.', 'a'],
    ['#/how', 'How it works', 'The capture session, the two ARKit configurations and the marker pipeline, with links into the source.', 'b'],
    ['#/demo', 'Marker lab', 'The three tracking markers drawn by a JS port of the app\'s Swift drawing code, next to the Swift render.', 'c'],
    ['#/about', 'About', 'What you need to build and run the real app in Xcode, and how to run this site.', 'a'],
  ],
};
