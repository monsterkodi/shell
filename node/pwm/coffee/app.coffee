win = (require 'remote').getCurrentWindow()

document.observe 'dom:loaded', ->
	console.log "dom:loaded" + "fark" +  $("master") 
	$("master").focus()

win.on 'focus', (event) ->
	$("master").focus()
	
document.on 'keydown', (event) ->
	console.log 'key ' + event.which #+ ' ' + String.fromCharCode(event.which)
	if event.which == 27 # escape
		win.hide()
		# ipc.sendSync 'hide' 
	if event.which == 13 # enter
		$("site").value = 'hello:'+$("master").value
		console.log 'check master', $("master").text, $("master").value
		
