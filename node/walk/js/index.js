var tree, walk;

walk = require('walkdir');

tree = walk('/');

tree.on('file', function(filename, stat) {
  return console.log(filename, stat.size);
});
