var mb, menubar;

menubar = require('menubar');

mb = menubar({
  dir: __dirname + '/..',
  preloadWindow: true
});

mb.on('ready', function() {
  console.log('app is ready');
});
