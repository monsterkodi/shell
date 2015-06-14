var ipc;

ipc = require('ipc');

window.onkeydown = function(event) {
  console.log('key ' + ' ' + String.fromCharCode(event.which) + ' ' + event.which);
  if (event.which === 27) {
    return ipc.sendSync('close');
  }
};
