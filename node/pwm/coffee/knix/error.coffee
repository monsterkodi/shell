#!!error 

module.exports = () ->
    Console = require './console'
    Console.tag 'error'
    Console.logInfo.apply Console, Array.prototype.slice.call(arguments, 0)
