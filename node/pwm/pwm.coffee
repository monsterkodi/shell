
shortcut = require 'global-shortcut'
menubar  = require 'menubar'

mb= menubar 
    dir:           __dirname + '/..'
    preloadWindow: true
    width:         309
    height:        122

showWindow = () ->
    win = mb.window
    win.show()
    win.setMinimumSize(309, 56)
    win.setMaximumSize(309, 192)
    windowWidth = win.getSize()[0]
    screenWidth = (require 'screen').getPrimaryDisplay().workAreaSize.width
    winPosX = Number(((screenWidth-windowWidth)/2).toFixed())
    win.setPosition winPosX, 0
    win
            
mb.on 'after-create-window', ->
    doc = mb.window.webContents
    shortcut.register 'ctrl+`', showWindow
    setTimeout showWindow, 10
