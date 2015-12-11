Q        = require 'q'
path     = require 'path'
_        = require 'lodash'
mkpath   = require 'mkpath'
chalk    = require 'chalk'
webshot  = require 'webshot'
process  = require 'process'
url      = require 'url'
fs       = require 'fs'
del      = require 'del'
open     = require 'opener'
progress = require 'progress2'
noon     = require 'noon'

log = console.log

urls = noon.parse fs.readFileSync './sites.crypt', encoding: 'utf8'

img = 'img'
map = {}
file = 'home.html'

if false
    del.sync img
    mkpath.sync img

bar = new progress ":bar :current"+chalk.gray("/#{urls.length}"),
    complete: chalk.bold.blue '█'
    incomplete: chalk.gray '█'
    width: 25
    total: urls.length+1
bar.tick 0

load = (u) ->
    d = Q.defer()
    r = url.parse u
    r = url.parse("http://#{u}") unless r.hostname?
    f = path.join r.hostname + (r.path != '/' and r.path.replace('/', '.') or '') + '.png'
    map[u] = 
        href: r.href
        img: f
    f = path.join img, f
    if fs.existsSync f
        fs.renameSync f, path.join(img, "."+map[u].img) 
        
    o = 
        windowSize:
            width: 1200
            height: 1200        
        shotSize:
            width: 'window'
            height: 'window'
        defaultWhiteBackground: true
    webshot u, f, o, (e) ->
        bar.tick 1
        if e  
            map[u].status = chalk.red 'failed'
            d.reject new Error e
        else
            map[u].status = chalk.green 'ok'
            d.resolve f
    d.promise

p = Q.allSettled ( load(u) for u in urls )

buildPage = ->
    html = "<html><head><title>home</title>"
    html += '<link rel="stylesheet" type="text/css" href="style.css">'
    html += '</head><body><div id="stage">'
    for u,i of map
        html += "<span class='site'><a href=#{i.href}><img src=#{img}/#{i.img} width=200 height=200 /></a></span>"
    for i in [0..6]    
        html += "<span class='site empty'></span>"
    html += "</div></body></html>"
    fs.writeFileSync file, html
    open "./#{file}"

Q.timeout p, 30000
    .fail -> 
        process.stdout.clearLine()
        process.stdout.cursorTo(0)
        log chalk.bold.yellow.bgRed '       timeout       '
    .then (results) -> 
        process.stdout.clearLine()
        process.stdout.cursorTo(0)
        for u,i of map
            f = path.join img, i.img
            c = path.join img, "."+i.img
            if not i.status?
                i.status = chalk.red 'timeout'
            if 'ok' != chalk.stripColor i.status
                if not fs.existsSync c
                    i.img = 'fail.png'
                else
                    fs.renameSync c, f
        log noon.stringify map, colors:true
        
        buildPage()
        
        process.exit()
