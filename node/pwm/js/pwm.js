
/*
00000000   000   000  00     00
000   000  000 0 000  000   000
00000000   000000000  000000000
000        000   000  000 0 000
000        00     00  000   000
 */
var BrowserWindow, Tray, app, createWindow, events, ipc, knx, path, shortcut, showWindow, toggleWindow, win;

shortcut = require('global-shortcut');

path = require('path');

app = require('app');

ipc = require('ipc');

events = require('events');

Tray = require('tray');

BrowserWindow = require('browser-window');

win = void 0;

knx = void 0;


/*
000   000  000   000  000  000   000  000       0000000    0000000 
000  000   0000  000  000   000 000   000      000   000  000      
0000000    000 0 000  000    00000    000      000   000  000  0000
000  000   000  0000  000   000 000   000      000   000  000   000
000   000  000   000  000  000   000  0000000   0000000    0000000
 */

ipc.on('knixlog', function(event, args) {
  console.log(args);
  return knx.webContents.send('logknix', args);
});


/*
 0000000  000   000   0000000   000   000
000       000   000  000   000  000 0 000
0000000   000000000  000   000  000000000
     000  000   000  000   000  000   000
0000000   000   000   0000000   00     00
 */

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


/*
000000000   0000000    0000000    0000000   000      00000000
   000     000   000  000        000        000      000     
   000     000   000  000  0000  000  0000  000      0000000 
   000     000   000  000   000  000   000  000      000     
   000      0000000    0000000    0000000   0000000  00000000
 */

toggleWindow = function() {
  if (win && win.isVisible()) {
    win.hide();
    return knx.hide();
  } else {
    knx.show();
    return win.show();
  }
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
    tray.on('clicked', toggleWindow);

    /*
    000   000  000   000  000   000
    000  000   0000  000   000 000 
    0000000    000 0 000    00000  
    000  000   000  0000   000 000 
    000   000  000   000  000   000
     */
    knx = new BrowserWindow({
      dir: cwd,
      preloadWindow: true,
      x: 0,
      y: 0,
      width: 658,
      height: 800,
      frame: false,
      show: true
    });
    knx.loadUrl('file://' + cwd + '/knx.html');

    /*
    000   000  000  000   000
    000 0 000  000  0000  000
    000000000  000  000 0 000
    000   000  000  000  0000
    00     00  000  000   000
     */
    win = new BrowserWindow({
      dir: cwd,
      preloadWindow: true,
      width: 364,
      height: 466,
      frame: false
    });
    win.loadUrl('file://' + cwd + '/index.html');
    shortcut.register('ctrl+`', toggleWindow);
    return setTimeout(showWindow, 10);
  });
};

createWindow();
