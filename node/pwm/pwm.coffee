
shortcut      = require 'global-shortcut'
app           = require 'app'
path          = require 'path'
Tray          = require 'tray'
BrowserWindow = require 'browser-window'

win = undefined

showWindow = () ->
    win.show() unless win.isVisible()
    win.setMinimumSize(364, 466)
    win.setMaximumSize(364, 466)
    windowWidth = win.getSize()[0]
    screenWidth = (require 'screen').getPrimaryDisplay().workAreaSize.width
    winPosX = Number(((screenWidth-windowWidth)/2).toFixed())
    win.setPosition winPosX, 0
    win

createWindow = () ->
    opts = 
        dir:            __dirname + '/..'
        index:          'file://' + __dirname + '/../index.html'
        preloadWindow:  true
        width:          364
        height:         466
        frame:          false
    
    app.on 'ready', () ->
        if app.dock then app.dock.hide()

        tray = new Tray path.join opts.dir, 'Icon.png'

        tray.on 'clicked', (e, bounds) ->
            if win && win.isVisible()
                win.hide()
            else
                showWindow()

        win = new BrowserWindow opts

        win.on 'blur', win.hide
        win.loadUrl opts.index
        shortcut.register 'ctrl+`', showWindow
        setTimeout showWindow, 10
              
createWindow()            
