blessed = require 'blessed'

screen = blessed.screen
    autoPadding: true
    smartCSR: true
    cursorShape: box
screen.title = 'blessed test'
screen.enableMouse()
box = blessed.box
    top: 'center'
    left: 'center'
    width: '50%'
    height: '90%'
    content: 'Hello {bold}world{/bold}!'
    tags: true
    border: type: 'line'
    style:
        fg: 'white'
        bg: 'black'
        border: fg: '#000088'
        hover: bg: 'green'

screen.append box
# screen.enableMouse(box)

# box.on 'click', (data) ->
#     box.setContent '{center}clicked.{/center}'
#     screen.render()
    
# box.key 'enter', (ch, key) ->
#     box.setContent '{right}Even different {yellow-fg}content{/yellow-fg}.{/right}\n'
#     box.setLine 1, 'bar'
#     box.insertLine 1, 'foo'
#     screen.render()

screen.key [ 'escape', 'C-c' ], (ch, key) -> process.exit 0
box.key    [ 'escape', 'C-c' ], (ch, key) -> process.exit 0

passwordBox = blessed.textbox
    censor: true
    top: 'center'
    left: 'center'
    width: '100%'
    height: 3
    border: type: 'bg'
    tags: true
    style:
        fg: 'yellow'
        bg: '#000033'
        border: bg: '#000088'

passwordBox.setValue "secret"
passwordBox.key [ 'escape', 'C-c' ], (ch, key) -> process.exit 0
    
box.append passwordBox

start = () ->    
    passwordBox.readInput (err,data) -> 
        
        if not data? then process.exit 0

        box.setContent data
        screen.render()
        start()
    
start()
screen.render()
