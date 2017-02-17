
log = () -> 
    str = ([].slice.call arguments, 0).join " "
    console.log str
$ = (id) -> document.getElementById id
sw  = () -> $('body').clientWidth
sh  = () -> $('body').clientHeight - $('chart').clientHeight
    
key = window.location.search.substring(1)
api = "https://www.quandl.com/api/v3/datasets/WIKI/"

queue = []

enqueue = (req) ->
    queue.push req
    
dequeue = () ->
    req = queue.shift()
    req.send() if req

getStock = (stock) ->

    s = Snap()
    s.attr
        viewBox: '0 0 1000 100'
        overflow: 'visible'
                        
    bg = s.rect()
    bg.attr
        id:     stock
        class:  'bg'
        width:  1000
        height: 97
        rx:     10
        ry:     10
        
    years = (s, delta, num, offset) ->
        x = offset
        for y in [0...num]
            mid = s.line()
            mid.attr
                class: 'time'
                x1: x
                y1: 0
                x2: x
                y2: 97
            x += delta
    
    years s, 24, 13, 24
    years s, 104, 4, 13*24+104

    title = s.text()
    title.attr
        x:     10
        y:     20
        class: 'title'
        text:  stock
    
    graph = (s, values, x, max, clss) ->
        y = 97-97*values[0]/max
        for i in [1...values.length]
            v = values[i]
            l = s.line()
            x += 2
            ny = 97-97*v/max
            l.attr
                class: clss
                x1: x-2
                y1: y
                x2: x
                y2: ny
            y = ny
    
    #000       0000000   000   000   0000000 
    #000      000   000  0000  000  000      
    #000      000   000  000 0 000  000  0000
    #000      000   000  000  0000  000   000
    #0000000   0000000   000   000   0000000 
    
    req = new XMLHttpRequest()
    req.stock = stock
    req.s = s
    req.addEventListener "load", () ->
        dequeue()
        data = JSON.parse @response
        set = data.dataset
        values = (d[1] for d in set.data)
        max = Math.max.apply null, values
        y = parseInt(set.data[0][0].substr 2,2)
        m = parseInt(set.data[0][0].substr 5,2)
        x = (y*12+m)*2
        graph @s, values, x, max, 'long'
        
    arg = 
        start_date:   "2000-01-01"
        end_date:     "2018-01-01"
        collapse:     "monthly"
        column_index: 11 # close adjusted
        order:        'asc'
    opt = ("#{k}=#{v}" for k,v of arg).join "&"
    req.open 'GET', "#{api}#{stock}.json?#{opt}&api_key=#{key}", true
    enqueue req
    
    #00     00  000  0000000  
    #000   000  000  000   000
    #000000000  000  000   000
    #000 0 000  000  000   000
    #000   000  000  0000000  

    req = new XMLHttpRequest()
    req.stock = stock
    req.s = s
    req.addEventListener "load", () ->        
        dequeue()        
        data = JSON.parse @response
        set = data.dataset
        values = (d[1] for d in set.data)
        max = Math.max.apply null, values
        x = 13*24
        graph @s, values, x, max, 'mid'
            
        # 0000000  000   000   0000000   00000000   000000000
        #000       000   000  000   000  000   000     000   
        #0000000   000000000  000   000  0000000       000   
        #     000  000   000  000   000  000   000     000   
        #0000000   000   000   0000000   000   000     000   

        req = new XMLHttpRequest()
        req.stock = @stock
        req.s = @s
        req.max = max
        req.addEventListener "load", () ->                
            dequeue()
            data = JSON.parse @response
            set = data.dataset
            values = (d[1] for d in set.data)
            max = @max
            x = 13*24+104*4
            graph @s, values, x, max, 'short'
            
        arg = 
            start_date:   "2017-01-01"
            end_date:     "2018-01-01"
            collapse:     "dayly"
            column_index: 11 # close adjusted
            order:        'asc'
        opt = ("#{k}=#{v}" for k,v of arg).join "&"
        req.open 'GET', "#{api}#{stock}.json?#{opt}&api_key=#{key}", true
        enqueue req
            
    arg = 
        start_date:   "2013-01-01"
        end_date:     "2018-01-01"
        collapse:     "weekly"
        column_index: 11 # close adjusted
        order:        'asc'
    opt = ("#{k}=#{v}" for k,v of arg).join "&"
    req.open 'GET', "#{api}#{stock}.json?#{opt}&api_key=#{key}", true
    enqueue req
    
window.onload = () ->
    getStock "AAPL"
    getStock "TSLA"
    getStock "SCTY"
    getStock "FB"
    getStock "GOOGL"
    getStock "AMZN"
    getStock "MSFT"
    getStock "BA"
    getStock "LMT"
    getStock "NOC"
    dequeue()
            
        