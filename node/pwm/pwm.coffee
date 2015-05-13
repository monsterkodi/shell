#!/usr/bin/env coffee  
log    = console.log

ansi   = require 'ansi-256-colors'
fs     = require 'fs'
path   = require 'path'
# util   = require 'util'
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

stash  = process.env.HOME+'/.config/pwm.stash'
master = undefined
sites  = {}

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
      version:{ abbr: 'v', flag: true, help: "show version", hidden: true }
args = nomnom.parse()

# log "ciphers:"
# log crypto.getCiphers()

getMaster = () ->
    return master if master
    master = ask.question fw(6)+bold + 'master?' + reset + '   ', 
        hideEchoBack: true
        mask:         fg(3,0,0) + '●' #'★'

genHash = (value) -> crypto.createHash('sha512').update(value).digest('hex')    

encrypt = (data, key) ->
    # log data
    cipher = crypto.createCipher 'aes-256-cbc-hmac-sha1', genHash(key)
    cipher.update data
    cipher.final()
    
decrypt = (data, key) ->
    log data
    log genHash(key)
    cipher = crypto.createDecipher 'aes-256-cbc-hmac-sha1', genHash(key)
    cipher.update data
    cipher.final()
    
writeStash = () ->
    jsonString = JSON.stringify(sites)
    encrypted = encrypt(jsonString, getMaster())
    fs.writeFileSync(stash, encrypted)

readStash = () ->
    if fs.existsSync(stash)
        encrypted = fs.readFileSync(stash)
        decrypted = decrypt(encrypted, getMaster())
        sites = JSON.parse(decrypted)
    else
        log 'no stash at', stash

if args.version
    v = '::package.json:version::'.split('.')
    log bold + BG(0,0,1)+ fw(23) + " p" + BG(0,0,2) + "w" + BG(0,0,3) + fw(23) + "m" + fg(1,1,5) + " " + fw(23) + BG(0,0,4) + " " +
               BG(0,0,5) + fw(23) + " " + v[0] + " " + BG(0,0,4) + fg(1,1,5) + '.' + BG(0,0,3) + fw(23) + " " + v[1] + " " + BG(0,0,2)  + fg(0,0,5) + '.' + BG(0,0,1)+ fw(23) + " " + v[2] + " "
    process.exit 0

if args.list
    readStash()
    log stash
    process.exit 0

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
00000000    0000000    0000000   0000000  000   000   0000000   00000000   0000000  
000   000  000   000  000       000       000 0 000  000   000  000   000  000   000
00000000   000000000  0000000   0000000   000000000  000   000  0000000    000   000
000        000   000       000       000  000   000  000   000  000   000  000   000
000        000   000  0000000   0000000   00     00   0000000   000   000  0000000  
###

default_config =
    charsets: ['abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVXYZ', '023456789', '_+-/:.!|']
    pattern:  [0,0,0,2,0,0,0,2,0,0,0,2,1,1,1]

makePassword = (hash) ->
    pw = ""
    ss = Math.floor(hash.length / config.pattern.length)
    for i in [0...config.pattern.length]        
        sum = 0
        for s in [0...ss]
            sum += parseInt(hash[i*ss+s], 16)
        cs  = config.charsets[config.pattern[i]]
        pw += cs[sum%cs.length]
    pw

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
    
hash = genHash(site+mstr) 
# log "hash:  " + BG(0,0,5)+hash+reset

readStash()
if sites[site]?
    config = sites[site]
else
    config = default_config
    sites[site] = config
    log sites
    writeStash()
    
password = makePassword hash, config
log(fw(6) + bold + 'password: ' + bold+fw(23)+password+reset)

copy.copy password
  
