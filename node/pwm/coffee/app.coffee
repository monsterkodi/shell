win          = (require 'remote').getCurrentWindow()
fs           = require 'fs'
clipboard    = require 'clipboard'
_url         = require './js/coffee/urltools'
password     = require './js/coffee/password' 
cryptools    = require './js/coffee/cryptools'
trim         = require 'lodash.trim'
pad          = require 'lodash.pad'
genHash      = cryptools.genHash
encrypt      = cryptools.encrypt
decrypt      = cryptools.decrypt
decryptFile  = cryptools.decryptFile
extractSite  = _url.extractSite
containsLink = _url.containsLink
jsonStr      = (a) -> JSON.stringify a, null, " "

error     = () -> alert(arguments)
mstr      = undefined
default_pattern = 'abcd+efgh+12'

masterChanged = () -> 
    mstr = $("master").value
    console.log 'master changed:' + mstr

document.observe 'dom:loaded', -> 
    $("master").focus()
    $("master").on 'input', masterChanged
    clip = clipboard.readText()
    if containsLink clip
        $("site").value = extractSite clip

win.on 'focus', (event) -> $("master").focus()
        
document.on 'keydown', (event) ->
    # console.log 'key ' + event.which #+ ' ' + String.fromCharCode(event.which)
    if event.which == 27 # escape
        win.hide()
    if event.which == 13 # enter
        # mstr = $("master").value
        # $("site").value = 'hello:'+mstr
        while $("master").value.length < 20
            $("master").value += 'x'
        console.log 'readStash'
        readStash main

undirty = -> console.log 'undirty'
dirty = -> console.log 'dirty'

###
 0000000  000000000   0000000    0000000  000   000
000          000     000   000  000       000   000
0000000      000     000000000  0000000   000000000
     000     000     000   000       000  000   000
0000000      000     000   000  0000000   000   000
###

stashFile = process.env.HOME+'/.config/pwm.stash'
stash     = {}
    
writeStash = () ->
    buf = new Buffer(JSON.stringify(stash), "utf8")
    cryptools.encryptFile stashFile, buf, mstr
    undirty()

readStash = (cb) ->
    if fs.existsSync stashFile
        console.log 'stash exists' + stashFile + ' ' + mstr
        decryptFile stashFile, mstr, (err, json) -> 
            if err?
                if err[0] == 'can\'t decrypt file'
                    console.log 'err[0]' + err
                    stash = undefined
                    cb()
                else
                    console.log 'err' + err
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
            seed:       false
            configs:    {}
        undirty()
        cb()

numConfigs = () ->
    keysIn(stash.configs).length

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
    console.log "hash:" + hash + "config:" + jsonStr(config)
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
    
listStash = (hash) ->
    
    data = [['site', 'password', 'pattern', 'seed'], ['', '', '', '']]
    for siteKey of stash.configs
        config = stash.configs[siteKey]
        url    = decrypt config.url, mstr      
        pwd    = (stash.decryptall or hash == siteKey) and makePassword(genHash(url+mstr), config) or ''
        pat    = (config.pattern == stash.pattern and ' ' or (stash.decryptall and config.pattern or '✓'))
        data.push [ 
            url
            pwd
            pat
            trim(config.seed).length and '✓' or ''
        ]
    data.push ['', '', '', '']
    
    if hash?
        config = stash.configs[hash]
        url    = decrypt config.url, mstr
        pass   = makePassword genHash(url+mstr), config
        clipboard.writeText pass
        console.log pass
        $("password").value = pass
        $("password").focus()
    else
        clipboard.clear()
        $("password").value = "?"
    console.log data
    
###
00     00   0000000   000  000   000
000   000  000   000  000  0000  000
000000000  000000000  000  000 0 000
000 0 000  000   000  000  000  0000
000   000  000   000  000  000   000
###

main = () ->

    if not stash?
        $("site").value = "no stash: " + mstr
        return

    if containsLink clipboard.readText()
        $("site").value = extractSite clipboard.readText()
    site = trim $("site").value

    console.log 'site: ' + site + 'mstr: ' + mstr
    if not site? or site.length == 0
        $("password").value = ""
    $("site").focus()
                    
    hash = genHash site+mstr

    if stash.configs?[hash]?
        listStash hash
    else
        newSite site
        
