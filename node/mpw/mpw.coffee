#!/usr/bin/env coffee  
ansi    = require 'ansi-256-colors'
fs      = require 'fs'
path    = require 'path'
_s      = require 'underscore.string'
_       = require 'lodash'
url     = require './coffee/url'
crypto  = require 'crypto'
bcrypt  = require 'bcrypt'
blessed = require 'blessed'
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

stashFile = process.env.HOME+'/.config/mpw.stash'
mstr      = undefined
stash     = {}

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
      list:   { abbr: 'l', flag: true, help: 'list known sites' }
      delete: { abbr: 'd', flag: true, help: 'delete site(s)' }
      stash:  { abbr: 's', flag: true, help: 'show stash' }
      reset:  { abbr: 'r', flag: true, help: 'delete stash' }
      version:{ abbr: 'v', flag: true, help: "show version", hidden: true }
args = nomnom.parse()

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
        stash = { sites: {} }        
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
        for siteKey of stash.sites
            url = decrypt stash.sites[siteKey].url, mstr        
            data.push [ 
                bold+fg(2,2,5)+url+reset
                fg(5,5,0)+makePassword(genHash(url+mstr), stash.sites[siteKey])+reset
                fw(6)+stash.sites[siteKey].pattern+reset
                fw(3)+stash.sites[siteKey].seed+reset
            ]
        
        list = blessed.listtable
            parent:         box
            data:           data
            # top:            'bottom'
            left:           'center'
            width:          '90%'
            height:         '50%'
            bottom: 0
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
                _.keysIn(stash.sites)[index-2]

        selectedSite = () ->
            if hash = selectedHash()
                stash.sites[hash]

        list.focus()
        if hash?
            list.select (_.indexOf _.keysIn(stash.sites), hash) + 2        
        screen.render()

        list.on 'keypress', (ch, k) -> 
            
            key = k.full
            
            if key == 'backspace' # delete current item
                index = list.getScroll()
                if index > 1
                    list.removeItem index
                    site = _.keysIn(stash.sites)[index-2]
                    delete stash.sites[site] 
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
                log list._maxes + ' ' + list.getItem(list.getScroll()).getText()
                edit = blessed.textbox
                    value: selectedSite().pattern
                    parent: list
                    left:   list._maxes[0]+list._maxes[1]+1
                    width:  list._maxes[2]                    
                    top:    list.getScroll()-1
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
                        log data
                        site = selectedSite()
                        site.pattern = data
                        writeStash()
                        listStash selectedHash()
                    
            if key == 'r'
                log 'reseed'
                
            if key == 'enter'
                if site = selectedSite()
                    url      = decrypt site.url, mstr
                    password = makePassword(genHash(url+mstr), site)
                    copy     = require 'copy-paste'
                    copy.copy password
                    log key.full
                    process.exit 0
        return
        
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
    
unlock()
        
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
        if url.containsLink(clipboard)
            site = url.extractSite clipboard
        else
            listStash()
            return
    else
        site = args._[0]
                    
    # stash.pattern = ask.question(fw(6)+bold + 'default:  ' + default_pattern + reset + '\n?         ', defaultInput: default_pattern)
    stash.pattern = default_pattern unless stash.pattern

    hash = genHash site+mstr
    # clr()
    # log fw(6)+bold+'site:     ' + fw(23)+BG(0,0,5)+site+reset

    if stash.sites?[hash]?
        # config = stash.sites[hash]
        # password = makePassword hash, config
        # log (fw(6) + bold + 'password: ' + bold+fw(23)+password+reset)
        listStash hash
    else
        config = {}
        config.url = encrypt site, mstr
        config.pattern = stash.pattern
        
        salt = ""
        while salt.length < config.pattern.length
            salt += bcrypt.genSaltSync(13).substr(10)
        config.seed = salt.substr(0, config.pattern.length)
        log (fw(6) + bold +  'new seed: ' +bold+fg(5,0,0)+config.seed+reset)
        stash.sites[hash] = config
        password = makePassword hash, config
        log (fw(6) + bold + 'password: ' + bold+fw(23)+password+reset)
            
        #     config.pattern = ask.question(fw(6)+bold + 'pattern:  ' + stash.pattern + reset + '\n?         ', defaultInput: stash.pattern)
        #     while 1
        #         salt = ""
        #         while salt.length < config.pattern.length
        #             salt += bcrypt.genSaltSync(13).substr(10)
        #         config.seed = salt.substr(0, config.pattern.length)
        #         log (fw(6) + bold +  'new seed: ' +bold+fg(5,0,0)+config.seed+reset)
        #         stash.sites[hash] = config
        #         password = makePassword hash, config
        #         log (fw(6) + bold + 'password: ' + bold+fw(23)+password+reset)
        #         # if ask.keyInYN(fw(6)+bold + 'ok?' + reset + '       ', guide:false) then break
        writeStash()
        listStash hash
        
        mstr = 0
            
        # if sites.length == 1
        #     copy = require 'copy-paste'
        #     copy.copy password
  
