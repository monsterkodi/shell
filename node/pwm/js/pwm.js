var BrowserWindow, Tray, app, createWindow, path, shortcut, showWindow, win;

shortcut = require('global-shortcut');

app = require('app');

path = require('path');

Tray = require('tray');

BrowserWindow = require('browser-window');

win = void 0;

showWindow = function() {
  var screenSize, screenWidth, winPosX, windowWidth;
  screenSize = (require('screen')).getPrimaryDisplay().workAreaSize;
  if (!win.isVisible()) {
    win.show();
  }
  win.setMinimumSize(364, 466);
  win.setMaximumSize(364, screenSize.height);
  windowWidth = win.getSize()[0];
  screenWidth = screenSize.width;
  winPosX = Number(((screenWidth - windowWidth) / 2).toFixed());
  win.setPosition(winPosX, 0);
  return win;
};

createWindow = function() {
  var opts;
  opts = {
    dir: __dirname + '/..',
    index: 'file://' + __dirname + '/../index.html',
    preloadWindow: true,
    width: 364,
    height: 800,
    frame: false
  };
  return app.on('ready', function() {
    var tray;
    if (app.dock) {
      app.dock.hide();
    }
    tray = new Tray(path.join(opts.dir, 'Icon.png'));
    tray.on('clicked', function(e, bounds) {
      if (win && win.isVisible()) {
        return win.hide();
      } else {
        return showWindow();
      }
    });
    win = new BrowserWindow(opts);
    win.on('blur', win.hide);
    win.loadUrl(opts.index);
    shortcut.register('ctrl+`', showWindow);
    return setTimeout(showWindow, 10);
  });
};

createWindow();
