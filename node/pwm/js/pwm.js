var mb, menubar, shortcut, showWindow;

shortcut = require('global-shortcut');

menubar = require('menubar');

mb = menubar({
  dir: __dirname + '/..',
  preloadWindow: true,
  width: 309,
  height: 120
});

showWindow = function() {
  var screen, screenWidth, win, winPosX, windowWidth;
  win = mb.window;
  win.show();
  win.setMinimumSize(309, 56);
  win.setMaximumSize(309, 192);
  windowWidth = win.getSize()[0];
  console.log("window:" + windowWidth);
  screen = require('screen');
  screenWidth = screen.getPrimaryDisplay().workAreaSize.width;
  console.log("screen:" + screenWidth);
  winPosX = ((screenWidth - windowWidth) / 2).toFixed();
  console.log("winposx:" + winPosX);
  win.setPosition(Number(winPosX), 0);
  return win;
};

mb.on('after-create-window', function() {
  var doc;
  console.log('after-create-window');
  doc = mb.window.webContents;
  shortcut.register('ctrl+`', showWindow);
  return setTimeout(showWindow, 10);
});
