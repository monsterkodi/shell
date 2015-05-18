#!/usr/bin/env coffee  
log    = console.log
ansi   = require 'ansi-256-colors'
fs     = require 'fs'
path   = require 'path'
_s     = require 'underscore.string'
_      = require 'lodash'
url    = require './coffee/url'
ask    = require 'readline-sync'
copy   = require 'copy-paste'
crypto = require 'crypto'
bcrypt = require 'bcrypt'

# colors
bold   = '\x1b[1m'
reset  = ansi.reset
fg     = ansi.fg.getRgb
BG     = ansi.bg.getRgb
fw     = (i) -> ansi.fg.grayscale[i]
BW     = (i) -> ansi.bg.grayscale[i]

stashFile = process.env.HOME+'/.config/pwm.stash'
master    = undefined
stash     = {}

error = () ->
    log BG(5,0,0) + bold + fg(5,5,0) + "[ERROR]" + reset + bold + " " + fg(5,3,0) + [].splice.call(arguments,0).join(' ') + reset
    process.exit 1

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
    
default_config =
    pattern: 'aaaa-aaa-aaaa|0000'    

makePassword = (hash, config) ->
    # log config
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

# log "ciphers:\n", crypto.getCiphers()

###
00     00   0000000    0000000  000000000  00000000  00000000 
000   000  000   000  000          000     000       000   000
000000000  000000000  0000000      000     0000000   0000000  
000 0 000  000   000       000     000     000       000   000
000   000  000   000  0000000      000     00000000  000   000
###

getMaster = () ->
    return master if master
    master = ask.question fw(6)+bold + 'master?' + reset + '   ', 
        hideEchoBack: true
        mask:         fg(3,0,0) + '●' + reset #'★'

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
    
readFromFile = (key, file) ->
    error 'no key?' if not key?
    if fs.existsSync file
        try
            encrypted = fs.readFileSync(file, fileEncoding)
        catch
            error 'can\'t read file at', file
        try
            return decrypt(encrypted, key)
        catch
            error 'can\'t decrypt file', fw(23)+file
    else
        error 'no file at', file
    
###
 0000000  000000000   0000000    0000000  000   000
000          000     000   000  000       000   000
0000000      000     000000000  0000000   000000000
     000     000     000   000       000  000   000
0000000      000     000   000  0000000   000   000
###
    
writeStash = (key) ->
    error 'no key?' if not key?
    buf = new Buffer(JSON.stringify(stash), "utf8")
    writeBufferToFile(buf, key, stashFile)

readStash = (key) ->
    if fs.existsSync stashFile
        json = readFromFile(key, stashFile)
    if json?
        stash = JSON.parse(json)
    else
        stash = { sites: {} }

###
000      000   0000000  000000000
000      000  000          000   
000      000  0000000      000   
000      000       000     000   
0000000  000  0000000      000   
###

if args.list
    readStash getMaster()
    for site of stash.sites
        url = decrypt stash.sites[site].url, getMaster()
        log bold+fw(23)+_s.lpad(url, 20), fg(5,5,0)+makePassword(genHash(site+mstr), stash.sites[site]), fw(10)+stash.sites[site].pattern+reset, fg(5,0,0)+stash.sites[site].seed+reset
    process.exit 0

if args.stash
    readStash getMaster()
    log stash
    process.exit 0
    
if args.reset
    try
        fs.unlinkSync stashFile
        log '...', stashFile, 'removed'
    catch
        error 'can\'t remove ', stashFile
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
    log bold + BG(0,0,1)+ fw(23) + " p" + BG(0,0,2) + "w" + BG(0,0,3) + fw(23) + "m" + fg(1,1,5) + " " + fw(23) + BG(0,0,4) + " " +
               BG(0,0,5) + fw(23) + " " + v[0] + " " + BG(0,0,4) + fg(1,1,5) + '.' + BG(0,0,3) + fw(23) + " " + v[1] + " " + BG(0,0,2)  + fg(0,0,5) + '.' + BG(0,0,1)+ fw(23) + " " + v[2] + " "
    process.exit 0


###
0000000    00000000  000      00000000  000000000  00000000
000   000  000       000      000          000     000     
000   000  0000000   000      0000000      000     0000000 
000   000  000       000      000          000     000     
0000000    00000000  0000000  00000000     000     00000000
###
    
if args.delete?
    readStash getMaster()
    deleted = 0
    for site in args._
        if stash.sites?[site]?
            stash.sites[site] = undefined
            deleted += 1
    log "...", deleted, "sites deleted"
    log stash.sites
    writeStash getMaster()
    process.exit 0

###
00000000    0000000    0000000  000000000  00000000  000   000  00000000   000    
000   000  000   000  000          000     000       000   000  000   000  000    
00000000   000000000  0000000      000     0000000   000   000  0000000    000    
000        000   000       000     000     000       000   000  000   000  000    
000        000   000  0000000      000     00000000   0000000   000   000  0000000
###

if not args.url
    clipboard = copy.paste()
    if url.containsLink(clipboard)
        args.url = clipboard
    else
        nomnom.parse('-h')
        process.exit 0
    # log "hashes:"
    # log crypto.getHashes()
    # s1 = bcrypt.genSaltSync(13)
    # s2 = bcrypt.genSaltSync(13)
    # s3 = bcrypt.genSaltSync(13)
    # log s1, s2, s3
    # log bcrypt.hashSync('B4c0/\/', s1)
    # log bcrypt.hashSync('B4c0/\/', s2)
    # log bcrypt.hashSync('B4c0/\/', s3)

###
00     00   0000000   000  000   000
000   000  000   000  000  0000  000
000000000  000000000  000  000 0 000
000 0 000  000   000  000  000  0000
000   000  000   000  000  000   000
###

site = args.url             
if url.containsLink(args.url)
    site = url.extractSite args.url
log fw(6)+bold+'site:     ' + fw(23)+BG(0,0,5)+site+reset

mstr = getMaster()
hash = genHash site+mstr

readStash mstr
if stash.sites?[hash]?
    config = stash.sites[hash]
    # log 'config for site:', config
else
    config = default_config
    config.url = encrypt site, mstr
    while 1
        config.seed = bcrypt.genSaltSync(13).substr(10, config.pattern.length)
        log (fw(6) + bold +  'new seed: ' +bold+fg(5,0,0)+config.seed+reset)
        stash.sites[hash] = config
        password = makePassword hash, config
        log (fw(6) + bold + 'password: ' + bold+fw(23)+password+reset)
        if ask.question(fw(6)+bold + 'ok?' + reset + '       ') == 'y' then break
    writeStash mstr
    readStash mstr

mstr = master = 0
    
password = makePassword hash, config
log (fw(6) + bold + 'password: ' + bold+fw(23)+password+reset)

copy.copy password
  
