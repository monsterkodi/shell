#!/usr/bin/env coffee  
log  = console.log
fs   = require 'fs'
path = require 'path'
_s   = require 'underscore.string'

if process.argv.length > 2
    for subdir in fs.readdirSync(process.env.PWD).filter( (f) -> 
        abspath = path.join(process.env.PWD,f)
        fs.existsSync(abspath) and 
        fs.statSync(abspath).isDirectory() )
        if _s.startsWith subdir, process.argv[2]
            log subdir
            process.exit(0)
