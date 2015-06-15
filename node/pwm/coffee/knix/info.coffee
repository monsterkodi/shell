#!!info

module.exports = () ->
    Console = require './console'
    Console.tag 'info'
    Console.logInfo.apply Console, Array.prototype.slice.call(arguments, 0)
