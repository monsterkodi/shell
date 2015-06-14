var mb, menubar, shortcut, showWindow;

shortcut = require('global-shortcut');

menubar = require('menubar');

mb = menubar({
  dir: __dirname + '/..',
  preloadWindow: true,
  width: 309,
  height: 122
});

showWindow = function() {
  var screenWidth, win, winPosX, windowWidth;
  win = mb.window;
  win.show();
  win.setMinimumSize(309, 56);
  win.setMaximumSize(309, 192);
  windowWidth = win.getSize()[0];
  screenWidth = (require('screen')).getPrimaryDisplay().workAreaSize.width;
  winPosX = Number(((screenWidth - windowWidth) / 2).toFixed());
  win.setPosition(winPosX, 0);
  return win;
};

mb.on('after-create-window', function() {
  var doc;
  doc = mb.window.webContents;
  shortcut.register('ctrl+`', showWindow);
  return setTimeout(showWindow, 10);
});
