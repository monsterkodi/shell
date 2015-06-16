knix = require './js/coffee/knix/knix'

document.observe 'dom:loaded', ->
    
    knix.init
        console: true
