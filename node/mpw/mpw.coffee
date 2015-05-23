#!/usr/bin/env coffee  
ansi        = require 'ansi-256-colors'
fs          = require 'fs'
path        = require 'path'
_s          = require 'underscore.string'
_url        = require './coffee/url'
blessed     = require 'blessed'
password    = require './coffee/password' 
cryptools   = require './coffee/cryptools'
sleep       = require 'sleep'
pad         = require 'lodash.pad'
trim        = require 'lodash.trim'
keysIn      = require 'lodash.keysIn'
reduce      = require 'lodash.reduce'
indexOf     = require 'lodash.indexOf'
random      = require 'lodash.random'
genHash     = cryptools.genHash
encrypt     = cryptools.encrypt
decrypt     = cryptools.decrypt
decryptFile = cryptools.decryptFile

extractSite = _url.extractSite
containsLink = _url.containsLink
jsonStr = (a) -> JSON.stringify a, null, " "

###
 0000000   0000000   000       0000000   00000000 
000       000   000  000      000   000  000   000
000       000   000  000      000   000  0000000  
000       000   000  000      000   000  000   000
 0000000   0000000   0000000   0000000   000   000
###

color = 
    bg:              '#111111'
    border:          '#222222'
    text:            'white'
    password:        'yellow'
    password_bg:     '#111111'
    password_border: '#202020'
    error_bg:        '#880000'
    error_border:    '#ff8800'
    dirty:           '#ff8800'

# colors
bold   = '\x1b[1m'
reset  = ansi.reset
fg     = ansi.fg.getRgb
BG     = ansi.bg.getRgb
fw     = (i) -> ansi.fg.grayscale[i]
BW     = (i) -> ansi.bg.grayscale[i]

default_pattern = 'abcd+efgh+12'
    
###
 0000000   00000000    0000000    0000000
000   000  000   000  000        000     
000000000  0000000    000  0000  0000000 
000   000  000   000  000   000       000
000   000  000   000   0000000   0000000 
###

nomnom = require("nomnom")
   .script("mpw")
   .options
      url:
         position: 0
         help:     "the url of the site"
         required: false
      reset:     { abbr: 'r',  flag: true, help: 'delete stash' }
      version:   { abbr: 'v',  flag: true, help: "show version", hidden: true }
      password:  { abbr: 'pw', help: "use this as master password", hidden: true }
      stash:     { help: "open this stash", hidden: true }
args = nomnom.parse()

stashFile = args.stash or process.env.HOME+'/.config/mpw.stash'
mstr      = args.password or undefined
stash     = {}
    
###
 0000000  000000000   0000000    0000000  000   000
000          000     000   000  000       000   000
0000000      000     000000000  0000000   000000000
     000     000     000   000       000  000   000
0000000      000     000   000  0000000   000   000
###
    
writeStash = () ->
    buf = new Buffer(JSON.stringify(stash), "utf8")
    cryptools.encryptFile stashFile, buf, mstr
    undirty()

readStash = (cb) ->
    if fs.existsSync stashFile
        decryptFile stashFile, mstr, (err, json) -> 
            if err?
                if err[0] == 'can\'t decrypt file'
                    stash = undefined
                    cb()
                else
                    error.apply @, err
            else
                stash = JSON.parse(json)
                undirty()
                cb()
    else
        stash = { pattern: default_pattern, configs: {} }        
        undirty()
        cb()

numConfigs = () ->
    keysIn(stash.configs).length

###
00000000   00000000   0000000  00000000  000000000
000   000  000       000       000          000   
0000000    0000000   0000000   0000000      000   
000   000  000            000  000          000   
000   000  00000000  0000000   00000000     000   
###
    
if args.reset
    try
        fs.unlinkSync stashFile
        console.log '...', stashFile, 'removed'
    catch
        console.log 'can\'t remove ', stashFile
    process.exit 0
    
    
###
000   000  00000000  00000000    0000000  000   0000000   000   000
000   000  000       000   000  000       000  000   000  0000  000
 000 000   0000000   0000000    0000000   000  000   000  000 0 000
   000     000       000   000       000  000  000   000  000  0000
    0      00000000  000   000  0000000   000   0000000   000   000
###

if args.version
    v = '::package.json:version::'.split('.')
    console.log bold + BG(0,0,1)+ fw(23) + " p" + BG(0,0,2) + "w" + BG(0,0,3) + fw(23) + "m" + fg(1,1,5) + " " + fw(23) + BG(0,0,4) + " " +
                BG(0,0,5) + fw(23) + " " + v[0] + " " + BG(0,0,4) + fg(1,1,5) + '.' + BG(0,0,3) + fw(23) + " " + v[1] + " " + BG(0,0,2)  + fg(0,0,5) + '.' + BG(0,0,1)+ fw(23) + " " + v[2] + " "
    process.exit 0

###
 0000000   0000000  00000000   00000000  00000000  000   000
000       000       000   000  000       000       0000  000
0000000   000       0000000    0000000   0000000   000 0 000
     000  000       000   000  000       000       000  0000
0000000    0000000  000   000  00000000  00000000  000   000
###

screen = blessed.screen
    autoPadding: true
    smartCSR:    true
    cursorShape: box
    resizeTimeout: 100
    artificialCursor: true
    
screen.title = 'mpw'

box = blessed.box
    parent:             screen
    top:                'center'
    left:               'center'
    width:              '90%'
    height:             '90%'
    content:            fw(6)+'{bold}mpw{/bold} ::package.json:version::'
    tags:               true
    dockBorders:        true
    border:             type: 'line'
    style:              
        fg:     color.text
        bg:     color.bg
        border: 
            fg: color.border
            bg: color.bg

screen.on 'resize', () ->
    log 'resize'

drawScreen = (ms) ->
    screen.draw(0, screen.lines.length - 1)
    screen.program.flush()
    sleep.usleep(ms*1000)

###
0000000    000  00000000   000000000  000   000
000   000  000  000   000     000      000 000 
000   000  000  0000000       000       00000  
000   000  000  000   000     000        000   
0000000    000  000   000     000        000   
###

isdirty = undefined
dirty = () ->
    if not isdirty?
        isdirty = blessed.element
            parent: box
            content: '▣' #'◥' 
            right: 1
            top: 0
            width: 1
            height: 1
            fg:     color.dirty
            bg:     color.bg
    screen.render()

undirty = () ->
    if isdirty?
        box.remove isdirty
        isdirty = undefined
        screen.render()
        
###
000   000  00000000  000   000  00000000   00000000   00000000   0000000   0000000
000  000   000        000 000   000   000  000   000  000       000       000     
0000000    0000000     00000    00000000   0000000    0000000   0000000   0000000 
000  000   000          000     000        000   000  000            000       000
000   000  00000000     000     000        000   000  00000000  0000000   0000000 
###

screen.on 'keypress', (ch, key) ->
    if key.full == 'C-c' then process.exit 0
    if key.full == 'escape' then process.exit 0
    # if key.full == 'q' then process.exit 0
    
###
000       0000000    0000000 
000      000   000  000      
000      000   000  000  0000
000      000   000  000   000
0000000   0000000    0000000 
###

log = () ->
    box.setContent box.content + '\n' + [].slice.call(arguments, 0).join(' ') + reset
    screen.render()

clr = () ->
    box.setContent reset
    screen.render()

###
00000000  00000000   00000000    0000000   00000000 
000       000   000  000   000  000   000  000   000
0000000   0000000    0000000    000   000  0000000  
000       000   000  000   000  000   000  000   000
00000000  000   000  000   000   0000000   000   000
###

error = () ->
    errorBox = blessed.message
        top:    'center'
        left:   'center'
        width:  '100%'
        height: 5
        border: type: 'bg'
        style:  
            bg:     color.error_bg
            border: bg: color.error_border    
    box.append errorBox  
    errorMessage = BG(5,0,0) + bold + fg(5,5,0) + "[ERROR]\n" + reset + bold + fg(5,3,0) + arguments[0] + '\n' + fg(5,5,0) + [].splice.call(arguments,1).join('\n') + reset
    errorBox.display errorMessage, 3, () -> process.exit 1
    
###
000      000   0000000  000000000
000      000  000          000   
000      000  0000000      000   
000      000       000     000   
0000000  000  0000000      000   
###

listStash = (hash) ->
    
        data = [[fw(1)+'site', 'password', 'pattern', 'seed'], ['', '', '', '']]
        for siteKey of stash.configs
            config = stash.configs[siteKey]
            url = decrypt config.url, mstr        
            data.push [ 
                bold+fg(2,2,5)+url+reset
                fg(5,5,0)+makePassword(genHash(url+mstr), config)+reset
                # fw(6)+config.pattern+reset
                fw(6)+(config.pattern==stash.pattern and ' ' or config.pattern)+reset
                # fw(3)+config.seed+reset
                fw(3)+(trim(config.seed).length and '✓' or '')+reset
            ]
        data.push ['', '', '', '']
        
        list = blessed.listtable
            parent: box
            data:   data
            top:    'center'
            left:   'center'
            width:  '80%'
            height: '80%'
            # left:           6
            # right:          6
            # top:            3
            # bottom:         2
            align:         'left'
            tags:          true
            keys:          true
            noCellBorders: true
            # invertSelected: true
            padding:        
                left:  2
                right: 2
            border: 
                type: 'line'
            style:  
                fg:     color.text
                border: 
                    fg: color.border
                    bg: color.bg
                cell: 
                  fg:   'magenta'
                  selected:
                      bg: color.bg

        selectedHash = () ->
            index = list.getScroll()
            if index > 1
                keysIn(stash.configs)[index-2]

        selectedConfig = () ->
            if hash = selectedHash()
                stash.configs[hash]
                
        ###
        00000000  0000000    000  000000000   0000000   0000000   000    
        000       000   000  000     000     000       000   000  000    
        0000000   000   000  000     000     000       000   000  000    
        000       000   000  000     000     000       000   000  000    
        00000000  0000000    000     000      0000000   0000000   0000000
        ###
        editColum = (column, cb) ->
            text = list.getItem(list.getScroll()).getText()
            left = reduce(list._maxes.slice(0,column), ((sum, n) -> sum+n+1), 0)
            # log list._maxes + ' ' + text
            edit = blessed.textbox
                value:  trim text.substr left, list._maxes[column]-2
                parent: list
                left:   left-1
                width:  list._maxes[column]+1
                top:    list.getScroll()-1
                align:  'left'
                height: 3
                tags:   true
                keys:   true
                border: 
                    type: 'line'
                style:  
                    fg:     color.text
                    border: 
                        fg: color.border
            screen.render()
            
            edit.on 'keypress', (ch, k) ->
                key = k.full
                if key == 'left'
                    screen 
            
            edit.on 'resize', () ->
                list.remove edit
                screen.render()    

            edit.readInput (err,data) ->
                list.remove edit
                screen.render()    
                if not err? and data?.length
                    cb data                

        ###
        00000000    0000000   000000000  000000000  00000000  00000000   000   000
        000   000  000   000     000        000     000       000   000  0000  000
        00000000   000000000     000        000     0000000   0000000    000 0 000
        000        000   000     000        000     000       000   000  000  0000
        000        000   000     000        000     00000000  000   000  000   000
        ###
        editPattern = () ->
            editColum 2, (pattern) ->
                if password.isValidPattern pattern
                    config = selectedConfig()
                    config.pattern = pattern
                    clearSeed config
                    dirty()
                    listStash selectedHash()

        createSite = () ->
            list.select numConfigs()+2
            editColum 0, (site) -> newSite site

        list.focus()
        if hash?
            list.select (indexOf keysIn(stash.configs), hash) + 2        
        screen.render()

        ###
        000   000  00000000  000   000   0000000
        000  000   000        000 000   000     
        0000000    0000000     00000    0000000 
        000  000   000          000          000
        000   000  00000000     000     0000000 
        ###
        list.on 'keypress', (ch, k) -> 
            
            key = k.full
            
            ###
            0000000    00000000  000      00000000  000000000  00000000
            000   000  000       000      000          000     000     
            000   000  0000000   000      0000000      000     0000000 
            000   000  000       000      000          000     000     
            0000000    00000000  0000000  00000000     000     00000000
            ###
            if key == 'backspace' # delete current item
                index = list.getScroll()
                if index > 1
                    list.removeItem index
                    site = keysIn(stash.configs)[index-2]
                    delete stash.configs[site] 
                    dirty()
                    
            if key == 's' # save
                writeStash()
                log 'saved'
                
            if key == 'r' # reload
                hash = selectedHash()
                readStash () -> listStash hash
                
            if key == 'p' # edit pattern
                if selectedConfig() then editPattern()
                                        
            if key == '/' # new seed
                if config = selectedConfig()
                    newSeed config
                    dirty()
                    listStash selectedHash()

            if key == '.' # clear seed
                if config = selectedConfig()
                    clearSeed config
                    dirty()
                    listStash selectedHash()
                
            if key == 'n' then createSite()
                
            ###
            00000000  000   000  000000000  00000000  00000000 
            000       0000  000     000     000       000   000
            0000000   000 0 000     000     0000000   0000000  
            000       000  0000     000     000       000   000
            00000000  000   000     000     00000000  000   000
            ###
            if key == 'enter'
                if not isdirty? and config = selectedConfig()
                    url      = decrypt config.url, mstr
                    copy     = require 'copy-paste'
                    copy.copy makePassword genHash(url+mstr), config
                    process.exit 0
                else
                    if list.getScroll() in [ 0, 1, numConfigs()+2]
                        createSite()
                    else 
                        editPattern()
                        
        return
        
###
000   000  00000000  000   000   0000000  000  000000000  00000000
0000  000  000       000 0 000  000       000     000     000     
000 0 000  0000000   000000000  0000000   000     000     0000000 
000  0000  000       000   000       000  000     000     000     
000   000  00000000  00     00  0000000   000     000     00000000
###

newSeed = (config) ->
    config.seed = cryptools.genSalt config.pattern.length
    
clearSeed = (config) ->
    config.seed = pad '', config.pattern.length, ' '
    
makePassword = (hash, config) ->
    password.make hash, config.pattern, config.seed
    
newSite = (site) ->
    return if not site?
    site = trim site
    return if site.length == 0
    config = {}
    config.url = encrypt site, mstr
    config.pattern = stash.pattern

    clearSeed config

    hash = genHash site+mstr
    stash.configs[hash] = config
    dirty()
    listStash hash
                
###
000   000  000   000  000       0000000    0000000  000   000
000   000  0000  000  000      000   000  000       000  000 
000   000  000 0 000  000      000   000  000       0000000  
000   000  000  0000  000      000   000  000       000  000 
 0000000   000   000  0000000   0000000    0000000  000   000
###
    
unlock = () ->
    
    passwordBox = blessed.textbox
        parent: box
        censor: '●'
        top:    'center'
        left:   'center'
        width:  '100%'
        height: 3
        border: type: 'bg'
        tags:   true
        style:  
            fg:     color.password
            bg:     color.password_bg
            border: bg: color.password_border
    screen.render()

    passwordBox.on 'keypress', (ch, key) ->
        if key.full == 'C-c' then process.exit 0
        if key.full == 'escape' then process.exit 0
    
    passwordBox.readInput (err,data) -> 
        if err? then process.exit 0
        mstr = data
        value = pad '', passwordBox.value.length, '●'
        while passwordBox.content.length <= passwordBox.width
            passwordBox.setContent(passwordBox.content + '●')
            passwordBox.render()
            drawScreen 2
        drawScreen 20
        box.remove passwordBox
        readStash main
            
###
00     00   0000000   000  000   000
000   000  000   000  000  0000  000
000000000  000000000  000  000 0 000
000 0 000  000   000  000  000  0000
000   000  000   000  000  000   000
###

main = () ->

    if not stash?
        unlock()
        return

    if args._.length == 0 # no url arguments provided
        clipboard = require('copy-paste').paste()
        if containsLink clipboard
            site = extractSite clipboard
        else
            listStash()
            return
    else
        site = args._[0]
                    
    hash = genHash site+mstr

    if stash.configs?[hash]?
        listStash hash
    else
        newSite site

if mstr?
    readStash main
else
    unlock()

###
00000000  000   000  000  000000000
000        000 000   000     000   
0000000     00000    000     000   
000        000 000   000     000   
00000000  000   000  000     000   
###

exit = () ->
    writeStash()
    mstr = 0
    process.exit 0
  
###
000000000   0000000   0000000     0000000 
   000     000   000  000   000  000   000
   000     000   000  000   000  000   000
   000     000   000  000   000  000   000
   000      0000000   0000000     0000000 
###
###

- 'nightrider' animation after password enter
- config:
    default pattern
    always add seed
    auto close time
    fully decrypted 
    
###
