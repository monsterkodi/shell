#!/usr/bin/env coffee  
log  = console.log
prof = require './coffee/prof'
str  = require './coffee/str'

prof 'start', 'ls'
ansi   = require 'ansi-256-colors'
fs     = require 'fs'
path   = require 'path'
util   = require 'util'
_s     = require 'underscore.string'
_      = require 'lodash'
moment = require 'moment'
# colors
bold   = '\x1b[1m'
reset  = ansi.reset
fg     = ansi.fg.getRgb
BG     = ansi.bg.getRgb
fw     = (i) -> ansi.fg.grayscale[i]
BW     = (i) -> ansi.bg.grayscale[i]

stats = # counters for (hidden) dirs/files
    num_dirs:       0
    num_files:      0
    hidden_dirs:    0
    hidden_files:   0
    maxOwnerLength: 0
    maxGroupLength: 0

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
      long:   { abbr: 'l', flag: true, help: 'include size and modification date' }
      owner:  { abbr: 'o', flag: true, help: 'include owner and group' }
      rights: { abbr: 'r', flag: true, help: 'include rights' }
      all:    { abbr: 'a', flag: true, help: 'show dot files' }
      dirs:   { abbr: 'd', flag: true, help: "show only dirs"  }
      files:  { abbr: 'f', flag: true, help: "show only files" }
      size:   { abbr: 's', flag: true, help: 'sort by size' }
      time:   { abbr: 't', flag: true, help: 'sort by time' }
      kind:   { abbr: 'k', flag: true, help: 'sort by kind' }
      pretty: { abbr: 'p', flag: true, help: 'pretty size and months' }
      recurse:{ abbr: 'R', flag: true, help: 'recurse into subdirs'}
      stats:  { abbr: 'i', flag: true, help: "show statistics" }
      bytes:  {            flag: true, help: 'include size',              hidden: true }
      date:   {            flag: true, help: 'include modification date', hidden: true }
      colors: {            flag: true, help: "shows available colors",    hidden: true }
      values: {            flag: true, help: "shows color values",        hidden: true }
      debug:  {            flag: true, help: "debug logs",                hidden: true }
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

if args.long
    args.bytes = true
    args.date  = true

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

colors = 
    'coffee':   [ bold+fg(4,4,0),  fg(1,1,0), fg(1,1,0) ] 
    'py':       [ bold+fg(0,2,0),  fg(0,1,0), fg(0,1,0) ]
    'rb':       [ bold+fg(4,0,0),  fg(1,0,0), fg(1,0,0) ] 
    'json':     [ bold+fg(4,0,4),  fg(1,0,1), fg(1,0,1) ] 
    'js':       [ bold+fg(5,0,5),  fg(1,0,1), fg(1,0,1) ] 
    'cpp':      [ bold+fg(5,4,0),  fw(1),     fg(1,1,0) ] 
    'h':        [      fg(3,1,0),  fw(1),     fg(1,1,0) ] 
    'pyc':      [      fw(5),      fw(1),     fw(1) ]
    'log':      [      fw(5),      fw(1),     fw(1) ]
    'log':      [      fw(5),      fw(1),     fw(1) ]
    'txt':      [      fw(20),     fw(1),     fw(2) ]
    'md':       [ bold+fw(20),     fw(1),     fw(2) ]
    'markdown': [ bold+fw(20),     fw(1),     fw(2) ]
    #
    '_default': [      fw(15),     fw(1),     fw(6) ]
    '_dir':     [ bold+BG(0,0,2)+fw(23), fg(1,1,5), fg(2,2,5) ]
    '_.dir':    [ bold+BG(0,0,1)+fw(23), fg(1,1,5), fg(2,2,5) ]
    '_arrow':     fw(1)
    '_header':  [ bold+BW(5)+fg(5,5,0),  fg(1,1,1) ]  
    #
    '_size':    { b: [fg(0,0,2)], kB: [fg(0,0,4), fg(0,0,2)], MB: [fg(1,1,5), fg(0,0,3)], TB: [fg(4,4,5), fg(2,2,5)] } 
    '_users':   { root:  fg(3,0,0), default: fg(1,0,1) }
    '_groups':  { wheel: fg(1,0,0), staff: fg(0,1,0), admin: fg(1,1,0), default: fg(1,0,1) }
    '_rights':  
                  'r+': bold+BW(1)+fg(1,1,1)
                  'r-': reset+BW(1) 
                  'w+': bold+BW(1)+fg(2,2,5)
                  'w-': reset+BW(1)
                  'x+': bold+BW(1)+fg(5,0,0)
                  'x-': reset+BW(1)

try
    username = require('userid').username(process.getuid())
    colors['_users'][username] = fg(0,4,0)
catch
    username = ""
    
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
nameString = (name, ext) -> " " + colors[colors[ext]? and ext or '_default'][0] + name + reset
dotString  = (      ext) -> colors[colors[ext]? and ext or '_default'][1] + "." + reset
extString  = (      ext) -> dotString(ext) + colors[colors[ext]? and ext or '_default'][2] + ext + reset
dirString  = (name, ext) -> 
    c = name and '_dir' or '_.dir'
    colors[c][0] + (name and " " + name or "") + 
    (if ext then colors['_dir'][1] + '.' + colors['_dir'][2] + ext else "") + " "
        
sizeString = (stat) -> 
    if stat.size < 1000
        colors['_size']['b'][0] + _s.lpad(stat.size, 10) + " "
    else if stat.size < 1000000
        if args.pretty 
            colors['_size']['kB'][0] + _s.lpad((stat.size / 1000).toFixed(0), 7) + " " + colors['_size']['kB'][1] + "kB "
        else
            colors['_size']['kB'][0] + _s.lpad(stat.size, 10) + " "
    else if stat.size < 1000000000
        if args.pretty 
            colors['_size']['MB'][0] + _s.lpad((stat.size / 1000000).toFixed(1), 7) + " " + colors['_size']['MB'][1] + "MB "
        else
            colors['_size']['MB'][0] + _s.lpad(stat.size, 10) + " "
    else 
        if args.pretty 
            colors['_size']['TB'][0] + _s.lpad((stat.size / 1000000000).toFixed(3), 7) + " " + colors['_size']['TB'][1] + "TB "
        else
            colors['_size']['TB'][0] + _s.lpad(stat.size, 10) + " "
    
timeString = (stat) -> 
    t = moment(stat.mtime) 
    fw(16) + t.format("DD") + fw(7)+'.' + 
    (if args.pretty then fw(14) + t.format("MMM") + fw(1)+"'" else fw(14) + t.format("MM") + fw(1)+"'") +
    fw( 4) + t.format("YY") + " " +
    fw(16) + t.format("hh") + col = fw(7)+':' + 
    fw(14) + t.format("mm") + col = fw(1)+':' +
    fw( 4) + t.format("ss") + " "
    
ownerName = (stat) -> 
    try
        require('userid').username(stat.uid)
    catch
        stat.uid        
    
groupName = (stat) ->
    try
        require('userid').groupname(stat.gid)
    catch
        stat.gid    
    
ownerString = (stat) ->
    own = ownerName(stat)
    grp = groupName(stat)
    ocl = colors['_users'][own]
    ocl = colors['_users']['default'] unless ocl
    gcl = colors['_groups'][grp]
    gcl = colors['_groups']['default'] unless gcl
    ocl + _s.rpad(own, stats.maxOwnerLength) + " " + gcl + _s.rpad(grp, stats.maxGroupLength)
     
rwxString = (mode, i) ->
    (((mode >> (i*3)) & 0b100) and colors['_rights']['r+'] + ' r' or colors['_rights']['r-'] + '  ') + 
    (((mode >> (i*3)) & 0b010) and colors['_rights']['w+'] + ' w' or colors['_rights']['w-'] + '  ') +
    (((mode >> (i*3)) & 0b001) and colors['_rights']['x+'] + ' x' or colors['_rights']['x-'] + '  ')
    
rightsString = (stat) ->
    ur = rwxString(stat.mode, 2) + " "
    gr = rwxString(stat.mode, 1) + " "
    ro = rwxString(stat.mode, 0) + " "
    ur + gr + ro + reset
     
###
00000000  000  000      00000000   0000000
000       000  000      000       000     
000000    000  000      0000000   0000000 
000       000  000      000            000
000       000  0000000  00000000  0000000 
###
        
listFiles = (p, files) ->
    dirs = [] # visible dirs
    fils = [] # visible files
    dsts = [] # dir stats
    fsts = [] # file stats
    exts = [] # file extensions
    
    if args.owner
        files.forEach (rp) ->     
            if rp[0] == '/'
                file = path.resolve(rp)
            else
                file  = path.join(p, rp)
            try
                stat = fs.lstatSync(file)
                ol = ownerName(stat).length
                gl = groupName(stat).length
                if ol > stats.maxOwnerLength
                    stats.maxOwnerLength = ol
                if gl > stats.maxGroupLength
                    stats.maxGroupLength = gl
            catch
                return
                
    files.forEach (rp) -> 
        if rp[0] == '/'
            file = path.resolve(rp)
        else
            file  = path.join(p, rp)
        try    
            lstat = fs.lstatSync(file)
            link  = lstat.isSymbolicLink()
            stat  = link and fs.statSync(file) or lstat
        catch
            # log 'failed: ' + file
            return
            
        d    = path.parse file
        ext  = d.ext.substr(1)
        name = d.name
        if name[0] == '.'
            ext = name.substr(1) + d.ext
            name = ''
        if name.length or args.all
            s = " " 
            if args.rights
                s += rightsString(stat)
                s += " "                
            if args.owner
                s += ownerString(stat)
                s += " "
            if args.bytes
                s += sizeString stat
            if args.date
                s += timeString stat
            if stat.isDirectory() 
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
        
    if args.paths.length == 1 and args.paths[0] == '.' and not args.recurse
        log reset
    else
        s = colors['_arrow'] + "►" + colors['_header'][0] + " "
        ps = path.resolve(ps) if ps[0] != '~'
        if _s.startsWith(ps, process.env.PWD)
            ps = "./" + ps.substr(process.env.PWD.length)
        else if _s.startsWith(p, process.env.HOME)
            ps = "~" + p.substr(process.env.HOME.length)
            
        if ps == '/'
            s += '/'
        else
            sp = ps.split('/')
            s += colors['_header'][0] + sp.shift()
            for pn in sp
                if pn 
                    s += colors['_header'][1] + '/'
                    s += colors['_header'][0] + pn     
        log reset
        log s + " " + reset
        log reset
        
    try
        listFiles(p, fs.readdirSync(p))
        
        if args.recurse
            for pr in fs.readdirSync(p).filter( (f) -> fs.statSync(path.join(p,f)).isDirectory() )
                listDir(path.resolve(path.join(p, pr)))

    catch error
        msg = error.message
        msg = "permission denied" if _s.startsWith(msg, "EACCES")
        log " " + BG(5,0,0)+" "+fg(5,5,0)+bold+msg+" "+reset
    
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
    
log ""
if args.stats
    log BW(1) + " " +
    fw(8) + "%d".fmt(stats.num_dirs) + (stats.hidden_dirs and fw(4) + "+" + fw(5) + (stats.hidden_dirs) or "") + fw(4) + " dirs " + 
    fw(8) + "%d".fmt(stats.num_files) + (stats.hidden_files and fw(4) + "+" + fw(5) + (stats.hidden_files) or "") + fw(4) + " files " + 
    fw(8) + "%2.1f".fmt(prof('end', 'ls')) + fw(4) + " ms" + " " +
    reset   
         
