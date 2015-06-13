menubar = require 'menubar'
mb = menubar 
    dir: __dirname + '/..'
    preloadWindow: true
mb.on 'ready', ->
    console.log 'app is ready'
    return
