###

000  000   000  00000000   000   000  000000000
000  0000  000  000   000  000   000     000   
000  000 0 000  00000000   000   000     000   
000  000  0000  000        000   000     000   
000  000   000  000         0000000      000   

###

class Input extends Widget

    init: (cfg, defs) =>

        cfg = _.def cfg, defs
        
        super cfg,
            type: 'input'
            elem: 'input'

        @elem.setAttribute 'size', 6
        @elem.setAttribute 'type', 'text'
        @elem.setAttribute 'inputmode', 'numeric'
        @elem.getValue = -> parseFloat @value
        @
