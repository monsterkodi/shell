walk = require 'walkdir'
tree = walk '/'

tree.on 'file', (filename, stat) -> console.log(filename, stat.size)