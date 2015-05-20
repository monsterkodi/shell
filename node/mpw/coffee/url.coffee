_s = require 'underscore.string'

#╭━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╮
#┃                                                                                                       extractSite ▢
#╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯

re = /(^|\s|(?:http[s]?:\/\/))(?:[\w-]+\.)+\w[\w-]+(?::[1-9]\d+)?(?:\/[\w\.-~]*)*[\?\w\d\+\-\.,;=&\/#%\$]*(?:\s|$)/

exports.extractSite = (str) ->
    r = /(^|\s|(?:http[s]?:\/\/))((?:[\w-]+\.)+\w[\w-]+)(?::[1-9]\d+)?(?:\/[\w\.-~]*)*[\?\w\d\+\-\.,;=&\/#%\$]*(?:\s|$)/
    s = str.match(r)[2]
    s = s.substr(4) if _s.startsWith(s, 'www.')
    s

#╭━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╮
#┃                                                                                                      containsLink ▢
#╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯

exports.containsLink = (str) -> str.search(re) >= 0

#╭━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╮
#┃                                                                                                       shortenLink ▢
#╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯

exports.shortenLink = (str,len) ->
   len = len or 10

   if ((s = str.indexOf('://')) > -1)
      str = str.substr(s + 3)
   if (str.indexOf('www.') == 0)
      str = str.substr(4)
   if ((s = str.lastIndexOf('?')) > -1)
      str = str.substr(0, s)
   if ((s = str.lastIndexOf('.htm')) > -1)
      str = str.substr(0, s)
   if ((s = str.lastIndexOf('/')) == str.length-1)
      str = str.substr(0, s)
   if (str.length > len)
      s = str.split('/')
      host = s.splice(0,1)[0].split('.')
      str = [host[host.length-2]].concat(s).join('/')
   if (str.length > len)
      s = str.split('/')
      if (s.length > 2)
         str = s[0] + "..." + s[s.length - 1]
   str
