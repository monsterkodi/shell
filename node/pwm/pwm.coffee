
shortcut = require 'global-shortcut'
menubar  = require 'menubar'

mb= menubar 
    dir:           __dirname + '/..'
    preloadWindow: true
    width:         309
    height:        196

showWindow = () ->
    mb.window.show()
    windowWidth = mb.window.getSize()[0]
    console.log "window:" + windowWidth
    screen   = require 'screen'
    screenWidth = screen.getPrimaryDisplay().workAreaSize.width
    console.log "screen:" + screenWidth
    winPosX = ((screenWidth-windowWidth)/2).toFixed()
    console.log "winposx:" + winPosX
    mb.window.setPosition(Number(winPosX), 0)
    mb.window
            
mb.on 'after-create-window', ->
    console.log 'after-create-window'
    doc = mb.window.webContents
    shortcut.register 'ctrl+`', showWindow
    setTimeout showWindow, 10
