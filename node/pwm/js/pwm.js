var mb, menubar, shortcut, showWindow;

shortcut = require('global-shortcut');

menubar = require('menubar');

mb = menubar({
  dir: __dirname + '/..',
  preloadWindow: true,
  width: 309,
  height: 196
});

showWindow = function() {
  var screen, screenWidth, winPosX, windowWidth;
  mb.window.show();
  windowWidth = mb.window.getSize()[0];
  console.log("window:" + windowWidth);
  screen = require('screen');
  screenWidth = screen.getPrimaryDisplay().workAreaSize.width;
  console.log("screen:" + screenWidth);
  winPosX = ((screenWidth - windowWidth) / 2).toFixed();
  console.log("winposx:" + winPosX);
  mb.window.setPosition(Number(winPosX), 0);
  return mb.window;
};

mb.on('after-create-window', function() {
  var doc;
  console.log('after-create-window');
  doc = mb.window.webContents;
  shortcut.register('ctrl+`', showWindow);
  return setTimeout(showWindow, 10);
});
