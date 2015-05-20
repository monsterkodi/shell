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
    bg:              'black'
    border:          '#090909'
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

stashFile = process.env.HOME+'/.config/pwm.stash'
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
   .script("pwm")
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
0000000    00000000  000      00000000  000000000  00000000
000   000  000       000      000          000     000     
000   000  0000000   000      0000000      000     0000000 
000   000  000       000      000          000     000     
0000000    00000000  0000000  00000000     000     00000000
###
    
if args.delete?
    readStash mstr
    deleted = 0
    for site in args._
        siteKey = genHash site+mstr
        if stash.sites?[siteKey]?
            stash.sites[siteKey] = undefined
            deleted += 1
    log "...", deleted, "site" + (deleted !=1 and 's' or '') + " deleted"
    writeStash()
    listStash()
    
###
000   000  00000000  00000000    0000000  000   0000000   000   000
000   000  000       000   000  000       000  000   000  0000  000
 000 000   0000000   0000000    0000000   000  000   000  000 0 000
   000     000       000   000       000  000  000   000  000  0000
    0      00000000  000   000  0000000   000   0000000   000   000
###

if args.version
    v = '::package.json:version::'.split('.')
    log bold + BG(0,0,1)+ fw(23) + " p" + BG(0,0,2) + "w" + BG(0,0,3) + fw(23) + "m" + fg(1,1,5) + " " + fw(23) + BG(0,0,4) + " " +
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
    
screen.title = 'pwm'

box = blessed.box
    parent:  screen
    top:     'center'
    left:    'center'
    width:   '80%'
    height:  '90%'
    content: fw(6)+'{bold}pwm{/bold} 0.1.0'
    tags:    true
    dockBorders: true
    ignoreDockContrast: true
    border:  type: 'line'
    style:   
        fg:     color.text
        bg:     color.bg
        border: fg: color.border

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

listStash = () ->
    
        data = [[fw(1)+'site', 'password', 'pattern', 'seed']]
        for siteKey of stash.sites
            url = decrypt stash.sites[siteKey].url, mstr        
            # data.push [bold+fw(23)+ url, 
            #             fg(5,5,0)+makePassword(genHash(url+mstr), stash.sites[siteKey]), 
            #             fw(10)+stash.sites[siteKey].pattern+reset, 
            #             fg(5,0,0)+stash.sites[siteKey].seed ]
            data.push [ 
                bold+fg(2,2,5)+url+reset
                fg(5,5,0)+makePassword(genHash(url+mstr), stash.sites[siteKey])+reset
                fw(6)+stash.sites[siteKey].pattern+reset
                fw(3)+stash.sites[siteKey].seed+reset
            ]
        
        passwordList = blessed.listtable
            parent: box
            data:   data
            top:    'center'
            left:   'center'
            width:  '100%'
            height: '80%'
            align:  'left'
            border: type: 'line'
            tags: true,
            keys: true,
            style:  
                fg:     color.text
                bg:     color.background
                border: fg: color.border

        passwordList.focus()
        screen.render()
        return

    
    # # clr()
    # # log '-STASH' + jsonStr(stash)
    # # if _.isEmpty stash.sites
    # #     log 'empty'
    # # else
    # passwordList = blessed.list
    #     # data:   [["a", "b"], ['c', 'd']]
    #     # top:    'center'
    #     # left:   'center'
    #     # width:  '100%'
    #     # height: '50%'
    #     # border: type: 'line'
    #     # style:  
    #     #     fg:     color.text
    #     #     bg:     color.background
    #     #     border: fg: color.border
    # 
    # # data = []
    # # for siteKey of stash.sites
    # #     # log siteKey
    # #     # url = decrypt stash.sites[siteKey].url, mstr        
    # #     data.append ["a", "b"] # [bold+fw(23)+_s.lpad(url, 20), fg(5,5,0)+makePassword(genHash(url+mstr), stash.sites[siteKey]), fw(10)+stash.sites[siteKey].pattern+reset, fg(5,0,0)+stash.sites[siteKey].seed ]
    # #     
    # # passwordList.setData([["a", "b"], ['c', 'd']])
    # passwordList.add "hello"
    # box.append passwordList  
    # screen.render()
    #         
    #     # url = decrypt stash.sites[siteKey].url, mstr
    #     # lst bold+fw(23)+_s.lpad(url, 20), fg(5,5,0)+makePassword(genHash(url+mstr), stash.sites[siteKey]), fw(10)+stash.sites[siteKey].pattern+reset, fg(5,0,0)+stash.sites[siteKey].seed    
        
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
        # screen.render()
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
    clr()
    log fw(6)+bold+'site:     ' + fw(23)+BG(0,0,5)+site+reset
    # lst mstr
    # log jsonStr(stash)

    if stash.sites?[hash]?
        config = stash.sites[hash]
        password = makePassword hash, config
        log (fw(6) + bold + 'password: ' + bold+fw(23)+password+reset)
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
        listStash()
        
        mstr = 0
            
        # if sites.length == 1
        #     copy = require 'copy-paste'
        #     copy.copy password
  
