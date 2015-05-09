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
fw     = (i) -> colors.fg.grayscale[i]
BW     = (i) -> colors.bg.grayscale[i]

###
 0000000   00000000    0000000    0000000
000   000  000   000  000        000     
000000000  0000000    000  0000  0000000 
000   000  000   000  000   000       000
000   000  000   000   0000000   0000000 
###

args = require("nomnom")
   .script("color-ls")
   .options
      paths:
         position: 0
         help: "the file(s) and/or folder(s) to display"
         list: true
      long:   { abbr: 'l', flag: true, help: 'include size and mtime information' }
      all:    { abbr: 'a', flag: true, help: 'show dot files (.*)' }
      dirs:   { abbr: 'd', flag: true, help: "show only dirs"  }
      files:  { abbr: 'f', flag: true, help: "show only files" }
      size:   { abbr: 's', flag: true, help: 'sort by size' }
      time:   { abbr: 't', flag: true, help: 'sort by time' }
      kind:   { abbr: 'k', flag: true, help: 'sort by kind' }
      stats:  { abbr: 'i', flag: true, help: "show statistics" }
      colors: {            flag: true, help: "shows available colors", hidden: true }
      values: {            flag: true, help: "shows color values",     hidden: true }
      debug:  {            flag: true, help: "debug logs",             hidden: true }
   .parse()

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

args.paths = ['.'] unless args.paths?.length > 0

if args.debug
    log BW(2) + fw(12) + str(args) + reset

###
 0000000   0000000   000       0000000   00000000    0000000
000       000   000  000      000   000  000   000  000     
000       000   000  000      000   000  0000000    0000000 
000       000   000  000      000   000  000   000       000
 0000000   0000000   0000000   0000000   000   000  0000000 
###

fileColors = 
    'coffee':  [ bold+fg(4,4,0),  fg(1,1,0), fg(1,1,0) ] 
    'py':      [ bold+fg(0,2,0),  fg(0,1,0), fg(0,1,0) ]
    'rb':      [ bold+fg(4,0,0),  fg(1,0,0), fg(1,0,0) ] 
    'json':    [ bold+fg(4,0,4),  fg(1,0,1), fg(1,0,1) ] 
    'js':      [ bold+fg(5,0,5),  fg(1,0,1), fg(1,0,1) ] 
    'cpp':     [ bold+fg(5,4,0),  fw(1),     fg(1,1,0) ] 
    'h':       [      fg(3,1,0),  fw(1),     fg(1,1,0) ] 
    'pyc':     [      fw(5),      fw(1),     fw(1) ]
    'log':     [      fw(5),      fw(1),     fw(1) ]
    'log':     [      fw(5),      fw(1),     fw(1) ]
    'txt':     [      fw(20),     fw(1),     fw(2) ]
    'md':      [      fw(20),     fw(1),     fw(2) ]
    'default': [      fw(15),     fw(1),     fw(6) ]
    
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
    
###
00000000   00000000   000  000   000  000000000
000   000  000   000  000  0000  000     000   
00000000   0000000    000  000 0 000     000   
000        000   000  000  000  0000     000   
000        000   000  000  000   000     000   
###
    
linkString = (file)      -> reset + fw(1) + fg(1,0,1) + " ► " + fg(4,0,4) + fs.readlinkSync(file)
nameString = (name, ext) -> " " + fileColors[fileColors[ext]? and ext or 'default'][0] + name + reset
dotString  = (      ext) -> fileColors[fileColors[ext]? and ext or 'default'][1] + "." + reset
extString  = (      ext) -> dotString(ext) + fileColors[fileColors[ext]? and ext or 'default'][2] + ext + reset
dirString  = (name, ext) -> 
    bold + bg(0,0,name and 2 or 1) + 
    (name and " " + fw(23) + name or "") +     
    (if ext then fg(1,1,5) + '.' + fg(2,2,5) + ext else "") + " "
    
sizeString = (stat)      -> fw(5) + _s.lpad(stat.size, 8) + " "
timeString = (stat)      -> 
    t = moment(stat.mtime) 
    fw(16) + t.format("DD") + fw(7)+'.' + 
    fw(14) + t.format("MM") + fw(1)+"'" + 
    fw( 4) + t.format("YY") + " " +
    fw(16) + t.format("hh") + col = fw(7)+':' + 
    fw(14) + t.format("mm") + col = fw(1)+':' +
    fw( 4) + t.format("ss") + " "
    
###
00000000  000  000      00000000   0000000
000       000  000      000       000     
000000    000  000      0000000   0000000 
000       000  000      000            000
000       000  0000000  00000000  0000000 
###
    
stats = # counters for (hidden) dirs/files
    num_dirs: 0
    num_files: 0
    hidden_dirs: 0
    hidden_files: 0
    
listFiles = (p, files) ->
    dirs = [] # visible dirs
    fils = [] # visible files
    dsts = [] # dir stats
    fsts = [] # file stats
    exts = [] # file extensions
    files.forEach (rp) -> 
        if rp[0] == '/'
            file = path.resolve(rp)
        else
            file  = path.join(p, rp)
        lstat = fs.lstatSync(file)
        link  = lstat.isSymbolicLink()
        stat  = link and fs.statSync(file) or lstat
            
        d    = path.parse file
        ext  = d.ext.substr(1)
        name = d.name
        if name[0] == '.'
            ext = name.substr(1) + d.ext
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
                    stats.num_files += 1
                else 
                    stats.hidden_files += 1
            else if stat.isDirectory() 
                if not args.files
                    s += dirString name, ext
                    if link 
                        s += linkString file
                    dirs.push s+reset
                    dsts.push stat
                    stats.num_dirs += 1
                else
                    stats.hidden_dirs += 1
            else
                fils.push "WTF?"+reset
        else
            if stat.isFile()
                stats.hidden_files += 1
            else if stat.isDirectory()
                stats.hidden_dirs += 1
        
    if args.size or args.kind or args.time
        if dirs.length and not args.files
            dirs = sort dirs, dsts
        if fils.length
            fils = sort fils, fsts, exts
            
    for d in dirs
        log d
                    
    for f in fils
        log f
            
###
0000000    000  00000000 
000   000  000  000   000
000   000  000  0000000  
000   000  000  000   000
0000000    000  000   000
###
                
listDir = (p) ->
    ps = p
    if _s.startsWith(p, process.env.HOME)
        ps = "~" + p.substr(process.env.HOME.length)
    if args.paths.length == 1 and args.paths[0] == '.'
        log reset
    else
        s = bold + fw(1) + "►" + BW(5) + " " + fg(5,5,0)
        if ps == '/'
            s += '/'
        else
            sp = ps.split('/')
            s += fg(5,5,0) + sp.shift()
            for pn in sp
                if pn 
                    s += fg(1,1,1) + '/'
                    s += fg(5,5,0) + pn     
        log reset
        log s + " " + reset
    listFiles(p, fs.readdirSync(p))
    
###
00     00   0000000   000  000   000
000   000  000   000  000  0000  000
000000000  000000000  000  000 0 000
000 0 000  000   000  000  000  0000
000   000  000   000  000  000   000
###
                
fileArgs = args.paths.filter( (f) -> not fs.statSync(f).isDirectory() )                
if fileArgs.length > 0
    log reset
    listFiles(process.cwd(), fileArgs)
    
for p in args.paths.filter( (f) -> fs.statSync(f).isDirectory() )
    listDir(p)

if args.stats
    log ""
    log BW(1) + " " +
    fw(8) + "%d".fmt(stats.num_dirs) + (stats.hidden_dirs and fw(4) + "+" + fw(5) + (stats.hidden_dirs) or "") + fw(4) + " dirs " + 
    fw(8) + "%d".fmt(stats.num_files) + (stats.hidden_files and fw(4) + "+" + fw(5) + (stats.hidden_files) or "") + fw(4) + " files " + 
    fw(8) + "%2.1f".fmt(prof('end', 'ls')) + fw(4) + " ms" + " " +
    reset        
