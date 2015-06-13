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
keysIn      = require 'lodash.keysin'
reduce      = require 'lodash.reduce'
indexOf     = require 'lodash.indexof'
random      = require 'lodash.random'
copy        = require 'copy-paste'
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
                stash.decryptall = false
                #log jsonStr stash
                undirty()
                cb()
    else
        stash = 
            pattern:    default_pattern 
            decryptall: false
            seed:       true
            configs:    {}
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
    console.log bold + BG(0,0,1)+ fw(23) + " m" + BG(0,0,2) + "p" + BG(0,0,3) + fw(23) + "w" + fg(1,1,5) + " " + fw(23) + BG(0,0,4) + " " +
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
    # resizeTimeout: 100
    artificialCursor: true
    style:              
        fg:     color.text
        bg:     color.bg
    
screen.title = 'mpw'

fill = blessed.box
    parent:             screen
    top: 0
    left: 0
    right: 0
    bottom: 0
    style:              
        bg:     'black'

box = blessed.box
    parent:      fill
    top:         'center'
    left:        'center'
    width:       '90%'
    height:      '90%'
    content:     fw(6) + ' {bold}mpw{/bold} '+ fw(3) + '::package.json:version::'
    tags:        true
    dockBorders: true
    border:      type: 'line'
    style:       
        fg:     color.text
        bg:     color.bg
        border: 
            fg: color.border
            bg: color.bg

drawScreen = (ms) ->
    screen.draw(0, screen.lines.length - 1)
    screen.program.flush()
    sleep.usleep(ms*1000)
    
###
 0000000  000      00000000   0000000   00000000   0000000     0000000   000   000
000       000      000       000   000  000   000  000   000  000   000   000 000 
000       000      0000000   000000000  0000000    0000000    000   000    00000  
000       000      000       000   000  000   000  000   000  000   000   000 000 
 0000000  0000000  00000000  000   000  000   000  0000000     0000000   000   000
###
clearBox = (id) ->
    while box.children.length
        box.children[0].destroy()
        # box.remove box.children[0]
            
configTable = undefined
stashTable = undefined
            
clearTables = () ->
    configTable?.destroy()            
    stashTable?.destroy()            
    configTable = undefined
    stashTable = undefined
            
###
000   000  00000000  000   000  00000000   00000000   00000000   0000000   0000000
000  000   000        000 000   000   000  000   000  000       000       000     
0000000    0000000     00000    00000000   0000000    0000000   0000000   0000000 
000  000   000          000     000        000   000  000            000       000
000   000  00000000     000     000        000   000  00000000  0000000   0000000 
###
    
handleKey = (key) ->
    switch key
        when 's' # save
            writeStash()
        when 'C-c', 'escape' 
            exit()        
    
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
    errorMessage = BG(5,0,0) + bold + fg(5,5,0) + "[ERROR]\n" + reset + 
                               bold + fg(5,3,0) + arguments[0] + '\n' + 
                               fg(5,5,0) + [].splice.call(arguments,1).join('\n') + reset
    errorBox.display errorMessage, 3, () -> process.exit 1
    
###
00000000  0000000    000  000000000   0000000   0000000   000    
000       000   000  000     000     000       000   000  000    
0000000   000   000  000     000     000       000   000  000    
000       000   000  000     000     000       000   000  000    
00000000  0000000    000     000      0000000   0000000   0000000
###

editColum = (list, column, cb) ->

    text = list.getItem(list.getScroll()).getText()
    left = reduce(list._maxes.slice(0,column), ((sum, n) -> sum+n+1), 0)
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
        border: type: 'line'
        style:  
            fg:     color.text
            bg:     'black'
            border: 
                fg: color.border
                bg: 'black'
    screen.render()
        
    edit.on 'resize', () ->
        list.remove edit
        screen.render()    

    edit.readInput (err,data) ->
        list.remove edit
        screen.render()    
        if not err?
            cb data                
    
###
000      000   0000000  000000000
000      000  000          000   
000      000  0000000      000   
000      000       000     000   
0000000  000  0000000      000   
###

stashTable = undefined
listStash = (hash) ->
    
        data = [[fw(1)+'site', 'password', 'pattern', 'seed'], ['', '', '', '']]
        for siteKey of stash.configs
            config = stash.configs[siteKey]
            url    = decrypt config.url, mstr      
            pwd    = (stash.decryptall or hash == siteKey) and makePassword(genHash(url+mstr), config) or ''
            pcol   = (hash == siteKey and fg(5,5,0) or fw(15))
            pat    = (config.pattern == stash.pattern and ' ' or (stash.decryptall and config.pattern or '✓'))
            data.push [ 
                bold + fg(2,2,5) + url + reset
                pcol + pwd + reset
                fw(6) + pat + reset
                fg(0,3,0) + (trim(config.seed).length and '✓' or '')+reset
            ]
        data.push ['', '', '', '']
        
        if hash?
            config = stash.configs[hash]
            url    = decrypt config.url, mstr
            copy.copy makePassword genHash(url+mstr), config
        else
            copy.copy ''
            
        clearTables()
        list = blessed.listtable
            parent:         box
            data:           data
            top:            'center'
            left:           'center'
            width:          '80%'
            height:         '80%'
            align:          'left'
            tags:           true
            keys:           true
            noCellBorders:  true
            invertSelected: false
            padding:        
                left:  2
                right: 2
            border: 
                type: 'line'
            style:  
                fg:     color.text
                bg:     'black'
                border: 
                    fg: color.border
                    bg: color.bg
                cell: 
                  fg:   'magenta'
                  selected:
                      fg: 'brightwhite'
                      bg: color.bg
        stashTable = list

        selectedHash = () ->
            index = list.getScroll()
            if index > 1
                keysIn(stash.configs)[index-2]

        selectedConfig = () ->
            if hash = selectedHash()
                stash.configs[hash]
                
        ###
        00000000    0000000   000000000  000000000  00000000  00000000   000   000
        000   000  000   000     000        000     000       000   000  0000  000
        00000000   000000000     000        000     0000000   0000000    000 0 000
        000        000   000     000        000     000       000   000  000  0000
        000        000   000     000        000     00000000  000   000  000   000
        ###
        editPattern = () ->
            editColum list, 2, (pattern) ->
                pattern = trim pattern
                pattern = stash.pattern if pattern.length == 0
                pattern = stash.pattern if not password.isValidPattern pattern
                config = selectedConfig()
                config.pattern = pattern
                clearSeed config
                dirty()
                listStash selectedHash()

        createSite = () ->
            list.select numConfigs()+2
            editColum list, 0, (site) -> newSite site

        list.on 'select', () -> 
            listStash selectedHash() if selectedHash()?
            
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
            
            switch key
                
                when 'backspace' # delete current item
                    ###
                    0000000    00000000  000      00000000  000000000  00000000
                    000   000  000       000      000          000     000     
                    000   000  0000000   000      0000000      000     0000000 
                    000   000  000       000      000          000     000     
                    0000000    00000000  0000000  00000000     000     00000000
                    ###
                    index = list.getScroll()
                    if index > 1
                        list.removeItem index
                        site = keysIn(stash.configs)[index-2]
                        delete stash.configs[site] 
                        dirty()
                        
                when 'r' # reload
                    hash = selectedHash()
                    readStash () -> listStash hash
                    
                when 'p' # edit pattern
                    if selectedConfig() then editPattern()
                                            
                when '/' # new seed
                    if config = selectedConfig()
                        newSeed config
                        dirty()
                        listStash selectedHash()

                when '.' # clear seed
                    if config = selectedConfig()
                        clearSeed config
                        dirty()
                        listStash selectedHash()
                    
                when 'n' then createSite()
                when ',' then listConfig()
                    
                when 'enter'
                    ###
                    00000000  000   000  000000000  00000000  00000000 
                    000       0000  000     000     000       000   000
                    0000000   000 0 000     000     0000000   0000000  
                    000       000  0000     000     000       000   000
                    00000000  000   000     000     00000000  000   000
                    ###
                    if list.getScroll() in [ 0, 1 ]
                        listConfig()
                    else if list.getScroll() == numConfigs()+2
                        createSite()
                else
                    handleKey key        
        
        return
    
###
 0000000   0000000   000   000  00000000  000   0000000 
000       000   000  0000  000  000       000  000      
000       000   000  000 0 000  000000    000  000  0000
000       000   000  000  0000  000       000  000   000
 0000000   0000000   000   000  000       000   0000000 
###
    
configTable = undefined    
listConfig = (index) ->
    cfg = [
        ['default pattern'   , 'pattern'   , 'string']
        ['seed new sites'    , 'seed'      , 'bool']
        ['show all passwords', 'decryptall', 'bool']
    ] 
    
    data = [
        [fw(1)+'setting' , 'value']
        [''              , ''     ]        
    ]
    
    for c in cfg
        vcol = fg(5,5,0)
        switch c[2]
            when 'bool'
                if stash[c[1]]
                    vcol = fg(0,3,0)
                    value = '✓'
                else
                    value = '❌'
            when 'int'
                value = String(stash[c[1]])
                vcol = fg(2,2,5)
            else
                value = stash[c[1]]
                
        data.push [ 
            bold + fw(9) + c[0] + reset
            vcol + value + reset
        ]
         
    clearTables()
    list = blessed.listtable
        id:             'config'
        parent:         box
        data:           data
        top:            'center'
        left:           'center'
        width:          '80%'
        height:         '80%'
        align:          'left'
        tags:           true
        keys:           true
        noCellBorders:  true
        invertSelected: false
        padding:        
            left:  2
            right: 2
        border: 
            type: 'line'
        style:  
            fg:     color.text
            bg:     'black'
            border: 
                fg: color.border
                bg: color.bg
            cell: 
              selected:
                  fg: 'brightwhite'
                  bg: color.bg
    configTable = list

    close = () -> listStash()
                          
    list.on 'keypress', (ch, k) ->
        
        key = k.full
        
        cfgIndex = index or list.getScroll()-2
        
        switch key
            
            when 'escape', ','
                close()
            
            when 'enter'
                if list.getScroll() == 1
                    close()
                else
                    if cfg[cfgIndex][2] == 'bool'
                        stash[cfg[cfgIndex][1]] = not stash[cfg[cfgIndex][1]]
                        if cfg[cfgIndex][1] != 'decryptall'
                            dirty()
                        listConfig index
                    else
                        editColum list, 1, (value) ->
                            if cfg[cfgIndex][2] == 'int'
                                value = parseInt value
                            stash[cfg[cfgIndex][1]] = value
                            dirty()
                            listConfig cfgIndex

            when 'space', 'left', 'right'
                if cfg[cfgIndex][2] == 'bool'
                    stash[cfg[cfgIndex][1]] = not stash[cfg[cfgIndex][1]]
                    dirty()
                    listConfig cfgIndex
            else
                handleKey key        
                
    list.select index+2 if index?
    list.focus()      
    screen.render()
          
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

    if stash.seed
        newSeed config
    else
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

    passwordBox.on 'keypress', (ch, k) -> 
        key = k.full
        if key != 's'
            handleKey k.full
    
    passwordBox.readInput (err,data) -> 
        if err? then process.exit 1
        mstr = data
        value = pad '', passwordBox.value.length, '●'
        while passwordBox.content.length <= passwordBox.width
            passwordBox.setContent(passwordBox.content + '●')
            passwordBox.render()
            drawScreen 2
        drawScreen 20
        passwordBox.destroy()
        readStash main
                
lock = () ->
    if isdirty? then return
    clearBox()
    screen.render()
    mstr           = undefined
    stash          = undefined
    copy.copy ''
    unlock()

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
            parent:  box
            content: '◉'
            top:     0
            right:   1
            height:  1
            width:   2
            fg:      color.dirty
            bg:      color.bg
            align:   'right'
            tags:    true
            style:   
                fg: color.password
                bg: color.password_bg
    screen.render()

undirty = () ->
    if isdirty?
        isdirty.destroy()
        isdirty = undefined
        screen.render()

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
        clipboard = copy.paste()
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

exit = () -> process.exit 0
  
###
000000000   0000000   0000000     0000000 
   000     000   000  000   000  000   000
   000     000   000  000   000  000   000
   000     000   000  000   000  000   000
   000      0000000   0000000     0000000 
###
###
    - backup files?
    - color dots
    - sort sites
###
