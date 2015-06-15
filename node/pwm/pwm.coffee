
shortcut      = require 'global-shortcut'
app           = require 'app'
path          = require 'path'
# events        = require 'events'
Tray          = require 'tray'
BrowserWindow = require 'browser-window'
defaults      = require 'lodash.defaults'

win = undefined

showWindow = () ->
    win.show()
    win.setMinimumSize(309, 56)
    win.setMaximumSize(309, 192)
    windowWidth = win.getSize()[0]
    screenWidth = (require 'screen').getPrimaryDisplay().workAreaSize.width
    winPosX = Number(((screenWidth-windowWidth)/2).toFixed())
    win.setPosition winPosX, 0
    win

createWindow = () ->

    opts = 
        dir:            __dirname + '/..'
        preloadWindow:  true
        width:          309
        height:         122
        frame:          false

    if not path.isAbsolute(opts.dir) then opts.dir = path.resolve opts.dir
    if not opts.index then opts.index = 'file://' + path.join opts.dir, 'index.html'

    app.on 'ready', () ->
        if app.dock then app.dock.hide()

        tray = new Tray path.join opts.dir, 'Icon.png'

        tray.on 'clicked', (e, bounds) ->
            if win && win.isVisible()
                win.hide()
            else
                win?.show()

        win = new BrowserWindow opts

        win.on 'blur', win.hide
        win.loadUrl opts.index
        shortcut.register 'ctrl+`', showWindow
        # setTimeout showWindow, 10
        showWindow()
      
createWindow()            
