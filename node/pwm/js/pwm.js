var BrowserWindow, Tray, app, createWindow, knx, path, shortcut, showWindow, win;

shortcut = require('global-shortcut');

path = require('path');

app = require('app');

Tray = require('tray');

BrowserWindow = require('browser-window');

win = void 0;

knx = void 0;

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
  return app.on('ready', function() {
    var cwd, iconFile, tray;
    if (app.dock) {
      app.dock.hide();
    }
    cwd = path.join(__dirname, '..');
    iconFile = path.join(cwd, 'Icon.png');
    tray = new Tray(iconFile);
    tray.on('clicked', function() {
      if (win && win.isVisible()) {
        win.hide();
        return knx.hide();
      } else {
        knx.show();
        return showWindow();
      }
    });
    knx = new BrowserWindow({
      dir: cwd,
      preloadWindow: true,
      x: 0,
      y: 0,
      width: 800,
      height: 800,
      frame: false,
      show: true
    });
    knx.loadUrl('file://' + cwd + '/knx.html');
    win = new BrowserWindow({
      dir: cwd,
      preloadWindow: true,
      width: 364,
      height: 466,
      frame: false
    });
    win.loadUrl('file://' + cwd + '/index.html');
    win.on('blur', win.hide);
    shortcut.register('ctrl+`', showWindow);
    return setTimeout(showWindow, 10);
  });
};

createWindow();
