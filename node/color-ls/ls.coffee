#!/usr/bin/env coffee  
log  = console.log
prof = require './coffee/prof'
str  = require './coffee/str'

prof 'start', 'ls'
colors = require 'ansi-256-colors'
fs     = require 'fs'
path   = require 'path'
util   = require 'util'
_s     = require 'underscore.string'
_      = require 'lodash'
moment = require 'moment'
# colors
bold   = '\x1b[1m'
reset  = colors.reset
fg     = colors.fg.getRgb
bg     = colors.bg.getRgb
bw     = (i) -> colors.fg.grayscale[i]
BW     = (i) -> colors.bg.grayscale[i]
# args
Parser = require('argparse').ArgumentParser
parser = new Parser
    version : '0.1.0',
    addHelp : true

parser.addArgument [ 'paths' ],         nargs:  '*',          help: 'the file(s) and/or folder(s) to display'
parser.addArgument [ '-l', '--long'  ], action: 'storeTrue',  help: 'include size and mtime information'
parser.addArgument [ '-a', '--all'   ], action: 'storeTrue',  help: 'include hidden files (.*)'
parser.addArgument [ '-s', '--size'  ], action: 'storeTrue',  help: 'sort by size'
parser.addArgument [ '-t', '--time'  ], action: 'storeTrue',  help: 'sort by time'
parser.addArgument [ '-k', '--kind'  ], action: 'storeTrue',  help: 'sort by kind'
parser.addArgument [ '-f', '--files' ], action: 'storeTrue',  help: 'show only files'
parser.addArgument [ '-d', '--dirs'  ], action: 'storeTrue',  help: 'show only directories'
parser.addArgument [ '-r', '--recursive' ], action: 'storeTrue',  help: 'recurse into subdirectories'
parser.addArgument [       '--stats' ], action: 'storeTrue',  help: 'show statistics'
parser.addArgument [      '--colors' ], action: 'storeTrue',  help: 'shows available colors'
parser.addArgument [      '--values' ], action: 'storeTrue',  help: 'shows color values'

args = parser.parseArgs()

if args.values
    c = require './coffee/colors'
    c.show_values()
    process.exit 0
    
if args.colors
    c = require './coffee/colors'
    c.show()
    process.exit 0
    
if args.size
    args.files = true
    
if args.paths.length == 0
    args.paths = ['.']

fileColors = 
    'coffee':  [ bold+fg(4,4,0),  fg(1,1,0), fg(1,1,0) ] 
    'py':      [ bold+fg(0,2,0),  fg(0,1,0), fg(0,1,0) ]
    'rb':      [ bold+fg(4,0,0),  fg(1,0,0), fg(1,0,0) ] 
    'json':    [ bold+fg(4,0,4),  fg(1,0,1), fg(1,0,1) ] 
    'js':      [ bold+fg(5,0,5),  fg(1,0,1), fg(1,0,1) ] 
    'cpp':     [ bold+fg(5,4,0),  bw(1),     fg(1,1,0) ] 
    'h':       [      fg(3,1,0),  bw(1),     fg(1,1,0) ] 
    'pyc':     [      bw(5),      bw(1),     bw(1) ]
    'log':     [      bw(5),      bw(1),     bw(1) ]
    'log':     [      bw(5),      bw(1),     bw(1) ]
    'txt':     [      bw(20),     bw(1),     bw(2) ]
    'md':      [      bw(20),     bw(1),     bw(2) ]
    'default': [      bw(15),     bw(1),     bw(6) ]
    
###
 0000000   0000000   00000000   000000000
000       000   000  000   000     000   
0000000   000   000  0000000       000   
     000  000   000  000   000     000   
0000000    0000000   000   000     000   
###
    
sort = (list, stats, exts=[]) ->
    l = _.zip list, stats, [0...list.length], (exts.length > 0 and exts or [0...list.length])
    if args.kind
        if exts == [] then return list
        l.sort((a,b) -> 
            if a[3] > b[3] then return 1 
            if a[3] < b[3] then return -1
            if args.time
                m = moment(a[1].mtime)
                if m.isAfter(b[1].mtime) then return 1
                if m.isBefore(b[1].mtime) then return -1
            if args.size
                if a[1].size > b[1].size then return 1
                if a[1].size < b[1].size then return -1
            if a[2] > b[2] then return 1
            -1)
    else if args.time
        l.sort((a,b) -> 
            m = moment(a[1].mtime)
            if m.isAfter(b[1].mtime) then return 1
            if m.isBefore(b[1].mtime) then return -1
            if args.size
                if a[1].size > b[1].size then return 1
                if a[1].size < b[1].size then return -1
            if a[2] > b[2] then return 1
            -1)
    else if args.size
        l.sort((a,b) -> 
            if a[1].size > b[1].size then return 1
            if a[1].size < b[1].size then return -1
            if a[2] > b[2] then return 1
            -1)
    _.unzip(l)[0]
    
linkString = (file)      -> reset + bw(1) + fg(1,0,1) + " ► " + fg(4,0,4) + fs.readlinkSync(file)
nameString = (name, ext) -> " " + fileColors[fileColors[ext]? and ext or 'default'][0] + name + reset
dotString  = (      ext) -> fileColors[fileColors[ext]? and ext or 'default'][1] + "." + reset
extString  = (      ext) -> dotString(ext) + fileColors[fileColors[ext]? and ext or 'default'][2] + ext + reset
dirString  = (name, ext) -> 
    bold + bg(0,0,name and 2 or 1) + 
    (name and " " + bw(23) + name or "") +     
    (if ext then fg(1,1,5) + '.' + fg(2,2,5) + ext else "") + " "
    
sizeString = (stat)      -> bw(5) + _s.lpad(stat.size, 8) + " "
timeString = (stat)      -> 
    t = moment(stat.mtime) 
    bw(16) + t.format("DD") + bw(7)+'.' + 
    bw(14) + t.format("MM") + bw(1)+"'" + 
    bw( 4) + t.format("YY") + " " +
    bw(16) + t.format("hh") + col = bw(7)+':' + 
    bw(14) + t.format("mm") + col = bw(1)+':' +
    bw( 4) + t.format("ss") + " "
    
###
000      000   0000000  000000000
000      000  000          000   
000      000  0000000      000   
000      000       000     000   
0000000  000  0000000      000   
###
    
listPath = (p) ->
    log reset
    fs.readdir p, (err, files) ->
        if err then throw err
        dirs = [] # visible dirs
        fils = [] # visible files
        dsts = [] # dir stats
        fsts = [] # file stats
        exts = [] # file extensions
        hidden = [0,0] # counters for hidden dirs/files
        files.map( (file) -> path.join(p, file) )
          .forEach (file) -> 
              
            lstat = fs.lstatSync(file)
            link  = lstat.isSymbolicLink()
            stat  = link and fs.statSync(file) or lstat
                
            d    = path.parse file
            ext  = d.ext.substr(1)
            name = d.name
            if name[0] == '.'
                ext = name.substr(1)
                name = ''
            if name.length or args.all
                s = " "
                if args.long
                    s += sizeString stat
                    s += timeString stat
                if stat.isFile() 
                    if not args.dirs
                        s += nameString name, ext
                        if ext 
                            s += extString ext
                        if link 
                            s += linkString file
                        fils.push s+reset
                        fsts.push stat
                        exts.push ext
                    else 
                        hidden[1] += 1
                else if stat.isDirectory() 
                    if not args.files
                        s += dirString name, ext
                        if link 
                            s += linkString file
                        dirs.push s+reset
                        dsts.push stat
                    else
                        hidden[0] += 1
                else
                    fils.push "WTF?"+reset
            else
                if stat.isFile()
                    hidden[1] += 1
                else if stat.isDirectory()
                    hidden[0] += 1
            
        if args.size or args.kind or args.time
            if dirs.length and not args.files
                dirs = sort dirs, dsts
            if fils.length
                fils = sort fils, fsts, exts
                
        for d in dirs
            log d
                        
        for f in fils
            log f
            
        if args.stats
            log ""
            log BW(1) + " " +
            bw(8) + "%d".fmt(dirs.length) + (hidden[0] and bw(4) + "+" + bw(5) + (hidden[0]) or "") + bw(4) + " dirs " + 
            bw(8) + "%d".fmt(fils.length) + (hidden[1] and bw(4) + "+" + bw(5) + (hidden[1]) or "") + bw(4) + " files " + 
            bw(8) + "%2.1f".fmt(prof('end', 'ls')) + bw(4) + " ms" + " " +
            reset        
    
for p in args.paths
    listPath(p)
