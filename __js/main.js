var agsModules = [{
  "id" : "tween",
  "name": "Tween",
  "text": "The AGS Tween Module allows you to programmatically interpolate many of the AGS properties (objects, characters, regions, viewport, audio, gui, gui controls, etc.) over time in amazing ways. The term tween comes from 'inbetweening'. It's typically used in Adobe Flash to indicate interpolation of an object from one keyframe to another.",
  "forum": "https://www.adventuregamestudio.co.uk/forums/index.php?topic=51820.0",
  "version" : "2.1.0",
  "author" : "Edmundito",
}, {
  "id" : "backgroundspeech",
  "name": "Background Speech",
  "text": "An easy way to get a character to say something in the background, while animating a speech view and playing a voice clip.",
  "forum": "https://www.adventuregamestudio.co.uk/forums/index.php?topic=35787.0",
  "version" : "1.1.0",
  "author" : "Electroshokker",
}, {
  "id" : "alternativekeyboardmovement",
  "name": "Alternative Keyboard Movement",
  "text": "A replacement for the Keyboard Movement module included in the Default Game Template.",
  "forum": "https://www.adventuregamestudio.co.uk/forums/index.php?topic=42843.0",
  "version" : "0.3.0",
  "author" : "Khris",
}, {
  "id" : "smoothscrollingandparallax",
  "name": "Smooth Scrolling and Parallax",
  "text": "Adds independent Smooth Scrolling camera and parallax effect on room objects.",
  "forum": "https://www.adventuregamestudio.co.uk/forums/index.php?topic=33142.0",
  "version" : "1.7.1",
  "author" : "Ali",
}, {
  "id" : "speechbubble",
  "name": "SpeechBubble",
  "text": "A module to do comic book-style speech bubbles. SpeechBubble is an alternative to Phylactere, because the older module doesn't work properly with 32-bit color.",
  "forum": "https://www.adventuregamestudio.co.uk/forums/index.php?topic=55542.0",
  "version" : "0.8.0",
  "author" : "Snarky",
}, {
  "id" : "hinthighlighting",
  "name": "Hint Highlighting",
  "text": "Adds an overlay which highlights all the visible and clickable objects, hotspots and charactes, to avoid pixel hunting and need of hints.",
  "forum": "https://www.adventuregamestudio.co.uk/forums/index.php?topic=56463.0",
  "version" : "2.2.0",
  "author" : "artium",
}, {
  "id" : "doubleclick",
  "name": "DoubleClick",
  "text": "AGS does not have built-in mouse double-click events. DoubleClick module solves this by detecting when player made two consecutive clicks within short duration.",
  "forum": "https://www.adventuregamestudio.co.uk/forums/index.php?topic=53226.0",
  "version" : "1.0.0",
  "author" : "Crimson Wizard",
}, {
  "id" : "keylistener",
  "name": "KeyListener",
  "text": "KeyListener is a more sophisticated script module, that keeps track and record of the particular key and mouse button states in your game. Since AGS is limited in which key and mouse events it reports to the script, this module may be a useful workaround.",
  "forum": "https://www.adventuregamestudio.co.uk/forums/index.php?topic=53226.0",
  "version" : "0.9.7",
  "author" : "Crimson Wizard",
}, {
  "id" : "totallipsync",
  "name": "TotalLipSync",
  "text": "TotalLipSync is a module for voice-based lip sync. It allows you to play back speech animations that have been synchronized with voice clips. TotalLipSync has all the same capabilities as the voice-based lip sync that is built into AGS, and offers the following additional advantage.",
  "forum": "https://www.adventuregamestudio.co.uk/forums/index.php?topic=54722.0",
  "version" : "0.5.0",
  "author" : "Snarky",
}, {
  "id" : "underwater",
  "name": "Underwater",
  "text": "Underwater distorts a background in a wibbly wavy way.",
  "forum": "https://www.adventuregamestudio.co.uk/forums/index.php?topic=38592.0",
  "version" : "1.1.0",
  "author" : "Kweepa",
}, {
  "id" : "easy3d",
  "name": "Easy3D",
  "text": "Easy way to create 3D games using the AGS editor. And add 3D parallax areas to normal 2D rooms.",
  "forum": "https://www.adventuregamestudio.co.uk/forums/index.php?topic=26130.0",
  "version" : "1.4.0",
  "author" : "Wretched",
}]

var idx = lunr(function () {
  this.ref('name')
  this.field('text')

  agsModules.forEach(function (doc) {
    this.add(doc)
  }, this)
})



