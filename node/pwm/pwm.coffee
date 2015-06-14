log = console.log

ipc      = require 'ipc'
shortcut = require 'global-shortcut'
menubar  = require 'menubar'

mb= menubar 
    dir:           __dirname + '/..'
    preloadWindow: true
    width:         200
    height:        94

showWindow = ->
    mb.window.show()
    mb.window.setPosition(800, 0)
            
mb.on 'after-create-window', ->
    doc = mb.window.webContents
    showWindow()
    shortcut.register 'ctrl+`', -> showWindow()

ipc.on 'hide', -> mb.window.hide()
