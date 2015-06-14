var mb, menubar, shortcut, showWindow;

shortcut = require('global-shortcut');

menubar = require('menubar');

mb = menubar({
  dir: __dirname + '/..',
  preloadWindow: true,
  width: 200,
  height: 110
});

showWindow = function() {
  mb.window.show();
  return mb.window.setPosition(800, 0);
};

mb.on('after-create-window', function() {
  var doc;
  doc = mb.window.webContents;
  shortcut.register('ctrl+`', function() {
    return showWindow();
  });
  return setTimeout(showWindow, 10);
});
