#!/usr/bin/env coffee  
ansi    = require 'ansi-256-colors'
fs      = require 'fs'
path    = require 'path'
_s      = require 'underscore.string'
_       = require 'lodash'
_url    = require './coffee/url'
crypto  = require 'crypto'
bcrypt  = require 'bcrypt'
blessed = require 'blessed'

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

# colors
bold   = '\x1b[1m'
reset  = ansi.reset
fg     = ansi.fg.getRgb
BG     = ansi.bg.getRgb
fw     = (i) -> ansi.fg.grayscale[i]
BW     = (i) -> ansi.bg.grayscale[i]

###
00000000    0000000    0000000   0000000  000   000   0000000   00000000   0000000  
000   000  000   000  000       000       000 0 000  000   000  000   000  000   000
00000000   000000000  0000000   0000000   000000000  000   000  0000000    000   000
000        000   000       000       000  000   000  000   000  000   000  000   000
000        000   000  0000000   0000000   00     00   0000000   000   000  0000000  
###

charsets = 
    'a': 'abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVXYZ'
    'b': 'abcdefghijkmnopqrstuvwxyz'
    '0': '023456789'
    '-': '+-._'
    '|': '\\/:!|'
    
default_pattern = 'aaaa-aaa-aaaa|0000'    

makePassword = (hash, config) ->
    pw = ""
    ss = Math.floor(hash.length / config.pattern.length)
    for i in [0...config.pattern.length]        
        sum = config.seed.charCodeAt i
        for s in [0...ss]
            sum += parseInt(hash[i*ss+s], 16)
        cs  = charsets[config.pattern[i]]
        pw += cs[sum%cs.length]
    pw
    
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
000   000   0000000    0000000  000   000
000   000  000   000  000       000   000
000000000  000000000  0000000   000000000
000   000  000   000       000  000   000
000   000  000   000  0000000   000   000
###
genHash = (value) -> crypto.createHash('sha512').update(value).digest('hex')    

###
 0000000  00000000   000   000  00000000   000000000   0000000 
000       000   000   000 000   000   000     000     000   000
000       0000000      00000    00000000      000     000   000
000       000   000     000     000           000     000   000
 0000000  000   000     000     000           000      0000000 
###

cipherType = 'aes-256-cbc'
fileEncoding = encoding:'utf8'

encrypt = (data, key) ->
    cipher = crypto.createCipher cipherType, genHash(key)
    enc =  cipher.update data, 'utf8', 'hex'
    enc += cipher.final 'hex'
    
decrypt = (data, key) ->
    cipher = crypto.createDecipher cipherType, genHash(key)
    dec  = cipher.update data, 'hex', 'utf8'
    dec += cipher.final 'utf8'
    
writeBufferToFile = (data, key, file) ->
    encrypted = encrypt data, key
    fs.writeFileSync file, encrypted, fileEncoding
    
readFromFile = (key, file, cb) ->
    if fs.existsSync file
        try
            encrypted = fs.readFileSync(file, fileEncoding)
        catch
            error 'can\'t read file at', file
            return
        try
            cb decrypt(encrypted, key)
        catch
            error 'can\'t decrypt file', file
    else
        error 'no file at', file
    
###
 0000000  000000000   0000000    0000000  000   000
000          000     000   000  000       000   000
0000000      000     000000000  0000000   000000000
     000     000     000   000       000  000   000
0000000      000     000   000  0000000   000   000
###
    
writeStash = () ->
    buf = new Buffer(JSON.stringify(stash), "utf8")
    writeBufferToFile(buf, mstr, stashFile)

readStash = (cb) ->
    if fs.existsSync stashFile
        readFromFile mstr, stashFile, (json) -> 
            stash = JSON.parse(json)
            cb()
    else
        stash = { configs: {} }        
        cb()

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
    
screen.title = 'mpw'

box = blessed.box
    parent:             screen
    top:                'center'
    left:               'center'
    width:              '90%'
    height:             '90%'
    content:            fw(6)+'{bold}mpw{/bold} ::package.json:version::'
    tags:               true
    shadow:             true
    dockBorders:        true
    ignoreDockContrast: true
    border:             type: 'line'
    style:              
        fg:     color.text
        bg:     color.bg
        border: 
            fg: color.border
            bg: color.bg

screen.on 'resize', () ->
    log 'resize'

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
            url = decrypt stash.configs[siteKey].url, mstr        
            data.push [ 
                bold+fg(2,2,5)+url+reset
                fg(5,5,0)+makePassword(genHash(url+mstr), stash.configs[siteKey])+reset
                fw(6)+stash.configs[siteKey].pattern+reset
                fw(3)+stash.configs[siteKey].seed+reset
            ]
        data.push ['', '', '', '']
        
        list = blessed.listtable
            parent:         box
            data:           data
            # top:            'center'
            bottom: 0
            left:           'center'
            width:          '90%'
            height:         '50%'
            align:          'left'
            tags:           true
            keys:           true
            noCellBorders:  true
            invertSelected: true
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
                _.keysIn(stash.configs)[index-2]

        selectedConfig = () ->
            if hash = selectedHash()
                stash.configs[hash]
                
        editColum = (column, cb) ->
            text = list.getItem(list.getScroll()).getText()
            left = _.reduce(list._maxes.slice(0,column), ((sum, n) -> sum+n+1), 0)
            # log list._maxes + ' ' + text
            edit = blessed.textbox
                value:  text.substr left, list._maxes[column]-2
                parent: list
                left:   left-1
                width:  list._maxes[column]+1
                top:    list.getScroll()-1
                align:  'center'
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
            edit.on 'resize', () ->
                list.remove edit
                screen.render()    
                                            
            edit.readInput (err,data) ->
                list.remove edit
                screen.render()    
                if not err? and data?.length
                    cb data                

        list.focus()
        if hash?
            list.select (_.indexOf _.keysIn(stash.configs), hash) + 2        
        screen.render()

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
                    site = _.keysIn(stash.configs)[index-2]
                    delete stash.configs[site] 
                    screen.render()
                    
            if key == 's'
                writeStash()
                log 'saved'
                
            ###
            00000000    0000000   000000000  000000000  00000000  00000000   000   000
            000   000  000   000     000        000     000       000   000  0000  000
            00000000   000000000     000        000     0000000   0000000    000 0 000
            000        000   000     000        000     000       000   000  000  0000
            000        000   000     000        000     00000000  000   000  000   000
            ###
            if key == 'p'
                editColum 2, (pattern) ->
                    config = selectedConfig()
                    config.pattern = pattern
                    newSeed config
                    writeStash()
                    listStash selectedHash()

            # if key == 'w'
            #     editColum 1, (data) ->
            #         log data
                    
            if key == 'r'
                log 'reseed'
                # editColum 3, (data) ->
                #     log data
                
            if key == 'n'
                list.select _.keysIn(stash.configs).length+2
                editColum 0, (site) ->
                    # if containsLink site
                    #     newSite extractSite site
                    newSite _.trim site
                
            if key == 'enter'
                if config = selectedConfig()
                    url      = decrypt config.url, mstr
                    password = makePassword(genHash(url+mstr), config)
                    copy     = require 'copy-paste'
                    copy.copy password
                    # log key.full
                    process.exit 0
                else
                    editColum 0, (site) ->
                        if containsLink site
                            newSite extractSite site
                        
        return
        
###
000   000  00000000  000   000   0000000  000  000000000  00000000
0000  000  000       000 0 000  000       000     000     000     
000 0 000  0000000   000000000  0000000   000     000     0000000 
000  0000  000       000   000       000  000     000     000     
000   000  00000000  00     00  0000000   000     000     00000000
###

newSeed = (config) ->
    salt = ""
    while salt.length < config.pattern.length
        salt += bcrypt.genSaltSync(13).substr(10)
    config.seed = salt.substr(0, config.pattern.length)    

newSite = (site) ->
    log site, mstr
    config = {}
    config.url = encrypt site, mstr
    config.pattern = stash.pattern

    newSeed config
    # log (fw(6) + bold +  'new seed: ' +bold+fg(5,0,0)+config.seed+reset)
    hash = genHash site+mstr
    stash.configs[hash] = config
    password = makePassword hash, config
    # log (fw(6) + bold + 'password: ' + bold+fw(23)+password+reset)
    writeStash()
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
    
    passwordBox.readInput (err,data) -> 
        
        if err? or not data?.length then process.exit 0
        box.remove passwordBox
        mstr = data
        readStash main
            
###
00     00   0000000   000  000   000
000   000  000   000  000  0000  000
000000000  000000000  000  000 0 000
000 0 000  000   000  000  000  0000
000   000  000   000  000  000   000
###

main = () ->

    if args._.length == 0 # no url arguments provided
        clipboard = require('copy-paste').paste()
        if containsLink clipboard
            site = extractSite clipboard
        else
            listStash()
            return
    else
        site = args._[0]
                    
    stash.pattern = default_pattern unless stash.pattern

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
- autoclose timeout
- join seed and pattern: full character set patterns
- don't show list fully decrypted by default
    
###
