###
00000000    0000000    0000000   0000000  000   000   0000000   00000000   0000000  
000   000  000   000  000       000       000 0 000  000   000  000   000  000   000
00000000   000000000  0000000   0000000   000000000  000   000  0000000    000   000
000        000   000       000       000  000   000  000   000  000   000  000   000
000        000   000  0000000   0000000   00     00   0000000   000   000  0000000  
###

zipObject = require 'lodash.zipobject'
indexOf   = require 'lodash.indexof'

charsets = [
    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVXYZ'
    '0123456789'
    '-+.><_='
    '|\\/:[]'   
    ]

setWithChar = (char) ->
    for set in charsets
        if indexOf(set, char) >= 0
            return set

make = (hash, config) ->
    pw = ""
    ss = Math.floor(hash.length / config.pattern.length)
    for i in [0...config.pattern.length]        
        sum = config.seed.charCodeAt i
        for s in [0...ss]
            sum += parseInt(hash[i*ss+s], 16)
        sum += config.pattern.charCodeAt i
        cs  = setWithChar config.pattern[i]
        pw += cs[sum%cs.length]
    pw
    
exportlist = 
    [
        'make'
    ]
module.exports = zipObject(exportlist.map((e) -> [e, eval(e)]))
