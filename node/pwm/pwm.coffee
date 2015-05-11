#!/usr/bin/env coffee  
log  = console.log

ansi   = require 'ansi-256-colors'
fs     = require 'fs'
path   = require 'path'
util   = require 'util'
_s     = require 'underscore.string'
_      = require 'lodash'
url    = require './coffee/url'
ask    = require 'readline-sync'
copy   = require 'copy-paste'
# colors
bold   = '\x1b[1m'
reset  = ansi.reset
fg     = ansi.fg.getRgb
BG     = ansi.bg.getRgb
fw     = (i) -> ansi.fg.grayscale[i]
BW     = (i) -> ansi.bg.grayscale[i]

###
 0000000   00000000    0000000    0000000
000   000  000   000  000        000     
000000000  0000000    000  0000  0000000 
000   000  000   000  000   000       000
000   000  000   000   0000000   0000000 
###

args = require("nomnom")
   .script("pwm")
   .options
      url:
         position: 0
         help:     "the url of the site"
         required: false
      version:{ abbr: 'v', flag: true, help: "show version", hidden: true }
   .parse()

if args.version
    v = '::package.json:version::'.split('.')
    log bold + BG(0,0,1)+ fw(23) + " p" + BG(0,0,2) + "w" + BG(0,0,3) + fw(23) + "m" + fg(1,1,5) + " " + fw(23) + BG(0,0,4) + " " +
               BG(0,0,5) + fw(23) + " " + v[0] + " " + BG(0,0,4) + fg(1,1,5) + '.' + BG(0,0,3) + fw(23) + " " + v[1] + " " + BG(0,0,2)  + fg(0,0,5) + '.' + BG(0,0,1)+ fw(23) + " " + v[2] + " "
    process.exit 0

if not args.url
    log "list"
    process.exit 0
    
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
log "site:" + BG(0,0,5)+site+reset

master = ask.question BG(5,2,3) + fw(1) + bold + 'Master Password:' + reset + ' ', 
  hideEchoBack: true
  mask: fg(5,2,3) + '\u2665'
    
log 'master is ', master
copy.copy master
  
