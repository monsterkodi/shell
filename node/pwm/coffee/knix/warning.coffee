#!!warning 

module.exports = () ->
    Console = require './console'
    Console.tag 'warning'
    Console.logInfo.apply Console, Array.prototype.slice.call(arguments, 0)
