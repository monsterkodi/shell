
shortcut = require 'global-shortcut'
menubar  = require 'menubar'

mb= menubar 
    dir:           __dirname + '/..'
    preloadWindow: true
    width:         200
    height:        110 # 60

showWindow = ->
    mb.window.show()
    mb.window.setPosition(800, 0)
            
mb.on 'after-create-window', ->
    doc = mb.window.webContents
    shortcut.register 'ctrl+`', -> showWindow()
    setTimeout showWindow, 10
