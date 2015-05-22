
/*
00000000    0000000    0000000   0000000  000   000   0000000   00000000   0000000  
000   000  000   000  000       000       000 0 000  000   000  000   000  000   000
00000000   000000000  0000000   0000000   000000000  000   000  0000000    000   000
000        000   000       000       000  000   000  000   000  000   000  000   000
000        000   000  0000000   0000000   00     00   0000000   000   000  0000000
 */
var charsets, exportlist, indexOf, make, setWithChar, zipObject;

zipObject = require('lodash.zipobject');

indexOf = require('lodash.indexof');

charsets = ['abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVXYZ', '0123456789', '-+.><_=', '|\\/:[]'];

setWithChar = function(char) {
  var j, len, set;
  for (j = 0, len = charsets.length; j < len; j++) {
    set = charsets[j];
    if (indexOf(set, char) >= 0) {
      return set;
    }
  }
};

make = function(hash, config) {
  var cs, i, j, k, pw, ref, ref1, s, ss, sum;
  pw = "";
  ss = Math.floor(hash.length / config.pattern.length);
  for (i = j = 0, ref = config.pattern.length; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
    sum = config.seed.charCodeAt(i);
    for (s = k = 0, ref1 = ss; 0 <= ref1 ? k < ref1 : k > ref1; s = 0 <= ref1 ? ++k : --k) {
      sum += parseInt(hash[i * ss + s], 16);
    }
    sum += config.pattern.charCodeAt(i);
    cs = setWithChar(config.pattern[i]);
    pw += cs[sum % cs.length];
  }
  return pw;
};

exportlist = ['make'];

module.exports = zipObject(exportlist.map(function(e) {
  return [e, eval(e)];
}));
