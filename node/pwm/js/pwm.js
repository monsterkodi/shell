var BrowserWindow, Tray, app, createWindow, defaults, path, shortcut, showWindow, win;

shortcut = require('global-shortcut');

app = require('app');

path = require('path');

Tray = require('tray');

BrowserWindow = require('browser-window');

defaults = require('lodash.defaults');

win = void 0;

showWindow = function() {
  var screenWidth, winPosX, windowWidth;
  win.show();
  win.setMinimumSize(309, 56);
  win.setMaximumSize(309, 192);
  windowWidth = win.getSize()[0];
  screenWidth = (require('screen')).getPrimaryDisplay().workAreaSize.width;
  winPosX = Number(((screenWidth - windowWidth) / 2).toFixed());
  win.setPosition(winPosX, 0);
  return win;
};

createWindow = function() {
  var opts;
  opts = {
    dir: __dirname + '/..',
    preloadWindow: true,
    width: 309,
    height: 122,
    frame: false
  };
  if (!path.isAbsolute(opts.dir)) {
    opts.dir = path.resolve(opts.dir);
  }
  if (!opts.index) {
    opts.index = 'file://' + path.join(opts.dir, 'index.html');
  }
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
        return win != null ? win.show() : void 0;
      }
    });
    win = new BrowserWindow(opts);
    win.on('blur', win.hide);
    win.loadUrl(opts.index);
    shortcut.register('ctrl+`', showWindow);
    return showWindow();
  });
};

createWindow();
