
/*
00000000    0000000    0000000   0000000  000   000   0000000   00000000   0000000  
000   000  000   000  000       000       000 0 000  000   000  000   000  000   000
00000000   000000000  0000000   0000000   000000000  000   000  0000000    000   000
000        000   000       000       000  000   000  000   000  000   000  000   000
000        000   000  0000000   0000000   00     00   0000000   000   000  0000000
 */
var charsets, exp, indexOf, isValidPattern, make, setWithChar, zipObject;

zipObject = require('lodash.zipobject');

indexOf = require('lodash.indexof');

charsets = ['abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVXYZ', '0123456789', '-', '.', '+=<>~', '!|@#$%^&*(){}[];:?,/_\'\"\`\\'];

setWithChar = function(char) {
  var j, len, set;
  for (j = 0, len = charsets.length; j < len; j++) {
    set = charsets[j];
    if (indexOf(set, char) >= 0) {
      return set;
    }
  }
};

isValidPattern = function(pattern) {
  var c, j, len;
  for (j = 0, len = pattern.length; j < len; j++) {
    c = pattern[j];
    if (setWithChar(c) == null) {
      return false;
    }
  }
  return true;
};

make = function(hash, pattern, seed) {
  var cs, i, j, k, pw, ref, ref1, s, ss, sum;
  pw = "";
  ss = Math.floor(hash.length / pattern.length);
  for (i = j = 0, ref = pattern.length; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
    sum = seed.charCodeAt(i);
    for (s = k = 0, ref1 = ss; 0 <= ref1 ? k < ref1 : k > ref1; s = 0 <= ref1 ? ++k : --k) {
      sum += parseInt(hash[i * ss + s], 16);
    }
    sum += pattern.charCodeAt(i);
    cs = setWithChar(pattern[i]);
    pw += cs[sum % cs.length];
  }
  return pw;
};

exp = ['make', 'isValidPattern'];

module.exports = zipObject(exp.map(function(e) {
  return [e, eval(e)];
}));
