###
000       0000000    0000000 
000      000   000  000      
000      000   000  000  0000
000      000   000  000   000
0000000   0000000    0000000 
###

log = () -> 
    Console = require '../windows/console'
    Console.logInfo.apply Console, Array.prototype.slice.call(arguments, 0)
    
dbg = () -> 
    Console = require '../windows/console'
    Console.logInfo.apply Console, Array.prototype.slice.call(arguments, 0)

info = () ->
    Console = require '../windows/console'
    Console.tag 'info'
    Console.logInfo.apply Console, Array.prototype.slice.call(arguments, 0)

warning = () ->
    Console = require '../windows/console'
    Console.tag 'warning'
    Console.logInfo.apply Console, Array.prototype.slice.call(arguments, 0)

error = () ->
    Console = require '../windows/console'
    Console.tag 'error'
    Console.logInfo.apply Console, Array.prototype.slice.call(arguments, 0)

exp = 
    [
        'log', 'dbg', 'info', 'warning', 'error'
    ]
module.exports = (require 'lodash.zipobject')(exp.map((e) -> [e, eval(e)]))
