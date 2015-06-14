var ipc, log, mb, menubar, shortcut, showWindow;

log = console.log;

ipc = require('ipc');

shortcut = require('global-shortcut');

menubar = require('menubar');

mb = menubar({
  dir: __dirname + '/..',
  preloadWindow: true,
  width: 200,
  height: 94
});

showWindow = function() {
  mb.window.show();
  return mb.window.setPosition(800, 0);
};

mb.on('after-create-window', function() {
  var doc;
  doc = mb.window.webContents;
  showWindow();
  return shortcut.register('ctrl+`', function() {
    return showWindow();
  });
});

ipc.on('close', function(event, arg) {
  return mb.window.hide();
});
