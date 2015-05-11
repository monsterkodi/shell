#!/usr/bin/env coffee  
log = console.log
colors = require 'ansi-256-colors'
_s     = require 'underscore.string'

# colors
bold   = '\x1b[1m'
reset  = colors.reset
fg     = colors.fg.getRgb
BG     = colors.bg.getRgb
fw     = (i) -> colors.fg.grayscale[i]
BW     = (i) -> colors.bg.grayscale[i]

path = process.argv[2]
if _s.startsWith(path, process.env.HOME)
    path = "~" + path.substr(process.env.HOME.length)

s = "  "
if path == '/'
    s += fg(4,3,0) + '/'
else
    for p in path.split('/')
        if p 
            s += fg(1,1,1) + '/' if p[0] != "~"
            s += fg(4,3,0) + p 
             
log BW(1) + bold + s + "  " + reset 
