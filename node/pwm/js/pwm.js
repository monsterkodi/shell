var BG, BW, _, _s, ansi, args, ask, bcrypt, bold, cipher, config, copy, crypto, fg, fs, fw, hash, log, makePassword, master, password, path, reset, s1, s2, s3, site, url, util, v;

log = console.log;

ansi = require('ansi-256-colors');

fs = require('fs');

path = require('path');

util = require('util');

_s = require('underscore.string');

_ = require('lodash');

url = require('./coffee/url');

ask = require('readline-sync');

copy = require('copy-paste');

crypto = require('crypto');

bold = '\x1b[1m';

reset = ansi.reset;

fg = ansi.fg.getRgb;

BG = ansi.bg.getRgb;

fw = function(i) {
  return ansi.fg.grayscale[i];
};

BW = function(i) {
  return ansi.bg.grayscale[i];
};


/*
 0000000   00000000    0000000    0000000
000   000  000   000  000        000     
000000000  0000000    000  0000  0000000 
000   000  000   000  000   000       000
000   000  000   000   0000000   0000000
 */

args = require("nomnom").script("pwm").options({
  url: {
    position: 0,
    help: "the url of the site",
    required: false
  },
  version: {
    abbr: 'v',
    flag: true,
    help: "show version",
    hidden: true
  }
}).parse();

if (args.version) {
  v = '0.0.1'.split('.');
  log(bold + BG(0, 0, 1) + fw(23) + " p" + BG(0, 0, 2) + "w" + BG(0, 0, 3) + fw(23) + "m" + fg(1, 1, 5) + " " + fw(23) + BG(0, 0, 4) + " " + BG(0, 0, 5) + fw(23) + " " + v[0] + " " + BG(0, 0, 4) + fg(1, 1, 5) + '.' + BG(0, 0, 3) + fw(23) + " " + v[1] + " " + BG(0, 0, 2) + fg(0, 0, 5) + '.' + BG(0, 0, 1) + fw(23) + " " + v[2] + " ");
  process.exit(0);
}

if (!args.url) {
  bcrypt = require('bcrypt');
  s1 = bcrypt.genSaltSync(13);
  s2 = bcrypt.genSaltSync(13);
  s3 = bcrypt.genSaltSync(13);
  log(s1, s2, s3);
  log(bcrypt.hashSync('B4c0/\/', s1));
  log(bcrypt.hashSync('B4c0/\/', s2));
  log(bcrypt.hashSync('B4c0/\/', s3));
  process.exit(0);
}


/*
00000000    0000000    0000000   0000000  000   000   0000000   00000000   0000000  
000   000  000   000  000       000       000 0 000  000   000  000   000  000   000
00000000   000000000  0000000   0000000   000000000  000   000  0000000    000   000
000        000   000       000       000  000   000  000   000  000   000  000   000
000        000   000  0000000   0000000   00     00   0000000   000   000  0000000
 */

config = {
  charsets: ['abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVXYZ', '023456789', '_+-/:.!|'],
  pattern: [0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 2, 1, 1, 1]
};

makePassword = function(hash) {
  var cs, i, j, k, pw, ref, ref1, s, ss, sum;
  pw = "";
  ss = Math.floor(hash.length / config.pattern.length);
  for (i = j = 0, ref = config.pattern.length; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
    sum = 0;
    for (s = k = 0, ref1 = ss; 0 <= ref1 ? k < ref1 : k > ref1; s = 0 <= ref1 ? ++k : --k) {
      sum += parseInt(hash[i * ss + s], 16);
    }
    cs = config.charsets[config.pattern[i]];
    pw += cs[sum % cs.length];
  }
  return pw;
};


/*
00     00   0000000   000  000   000
000   000  000   000  000  0000  000
000000000  000000000  000  000 0 000
000 0 000  000   000  000  000  0000
000   000  000   000  000  000   000
 */

site = args.url;

if (url.containsLink(args.url)) {
  site = url.extractSite(args.url);
}

log(fw(6) + bold + 'site:     ' + fw(23) + BG(0, 0, 5) + site + reset);

master = ask.question(fw(6) + bold + 'master?' + reset + '   ', {
  hideEchoBack: true,
  mask: fg(3, 0, 0) + '●'
});

hash = crypto.createHash('sha512').update(site + master).digest('hex');

log("hash:  " + BG(0, 0, 5) + hash + reset);

cipher = crypto.createCipher('aes-256-cbc', master);

password = makePassword(hash, config);

log(fw(6) + bold + 'password: ' + bold + fw(23) + password + reset);

copy.copy(password);
