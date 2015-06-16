
shortcut      = require 'global-shortcut'
path          = require 'path'
app           = require 'app'
Tray          = require 'tray'
BrowserWindow = require 'browser-window'

win = undefined
knx = undefined

showWindow = () ->
    screenSize = (require 'screen').getPrimaryDisplay().workAreaSize
    win.show() unless win.isVisible()
    win.setMinimumSize 364, 466
    win.setMaximumSize 364, screenSize.height
    windowWidth = win.getSize()[0]
    screenWidth = screenSize.width
    winPosX = Number(((screenWidth-windowWidth)/2).toFixed())
    win.setPosition winPosX, 0
    win

createWindow = () ->
    
    app.on 'ready', () ->

        if app.dock then app.dock.hide()

        cwd = path.join __dirname, '..'
        
        iconFile = path.join cwd, 'Icon.png'

        tray = new Tray iconFile
        
        tray.on 'clicked', () ->
            if win && win.isVisible()
                win.hide()
                knx.hide()
            else
                knx.show()
                showWindow()

        knx = new BrowserWindow
            dir:           cwd
            preloadWindow: true
            x:             0
            y:             0
            width:         800
            height:        800
            frame:         false
            show:          true
            
        knx.loadUrl 'file://' + cwd + '/knx.html'

        win = new BrowserWindow
            dir:           cwd
            preloadWindow: true
            width:         364
            height:        466
            frame:         false

        win.loadUrl 'file://' + cwd + '/index.html'
        
        win.on 'blur', win.hide
        
        shortcut.register 'ctrl+`', showWindow
        
        setTimeout showWindow, 10
              
createWindow()            
