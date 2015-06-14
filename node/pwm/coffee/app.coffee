ipc = require 'ipc'

window.onkeydown = (event) ->
	console.log 'key ' + ' ' + String.fromCharCode(event.which) + ' ' + event.which
	if event.which == 27 # escape
		ipc.sendSync 'hide'
