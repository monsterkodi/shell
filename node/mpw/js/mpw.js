var BG, BW, _, _s, _url, ansi, args, bcrypt, blessed, bold, box, charsets, cipherType, clr, color, containsLink, crypto, decrypt, default_pattern, encrypt, error, exit, extractSite, fg, fileEncoding, fs, fw, genHash, jsonStr, listStash, log, main, makePassword, mstr, newSeed, newSite, nomnom, path, readFromFile, readStash, reset, screen, stash, stashFile, unlock, v, writeBufferToFile, writeStash;

ansi = require('ansi-256-colors');

fs = require('fs');

path = require('path');

_s = require('underscore.string');

_ = require('lodash');

_url = require('./coffee/url');

crypto = require('crypto');

bcrypt = require('bcrypt');

blessed = require('blessed');

extractSite = _url.extractSite;

containsLink = _url.containsLink;

jsonStr = function(a) {
  return JSON.stringify(a, null, " ");
};


/*
 0000000   0000000   000       0000000   00000000 
000       000   000  000      000   000  000   000
000       000   000  000      000   000  0000000  
000       000   000  000      000   000  000   000
 0000000   0000000   0000000   0000000   000   000
 */

color = {
  bg: '#111111',
  border: '#222222',
  text: 'white',
  password: 'yellow',
  password_bg: '#111111',
  password_border: '#202020',
  error_bg: '#880000',
  error_border: '#ff8800'
};

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

stashFile = process.env.HOME + '/.config/mpw.stash';

mstr = void 0;

stash = {};


/*
00000000    0000000    0000000   0000000  000   000   0000000   00000000   0000000  
000   000  000   000  000       000       000 0 000  000   000  000   000  000   000
00000000   000000000  0000000   0000000   000000000  000   000  0000000    000   000
000        000   000       000       000  000   000  000   000  000   000  000   000
000        000   000  0000000   0000000   00     00   0000000   000   000  0000000
 */

charsets = {
  'a': 'abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVXYZ',
  'b': 'abcdefghijkmnopqrstuvwxyz',
  '0': '023456789',
  '-': '+-._',
  '|': '\\/:!|'
};

default_pattern = 'aaaa-aaa-aaaa|0000';

makePassword = function(hash, config) {
  var cs, i, j, l, pw, ref, ref1, s, ss, sum;
  pw = "";
  ss = Math.floor(hash.length / config.pattern.length);
  for (i = j = 0, ref = config.pattern.length; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
    sum = config.seed.charCodeAt(i);
    for (s = l = 0, ref1 = ss; 0 <= ref1 ? l < ref1 : l > ref1; s = 0 <= ref1 ? ++l : --l) {
      sum += parseInt(hash[i * ss + s], 16);
    }
    cs = charsets[config.pattern[i]];
    pw += cs[sum % cs.length];
  }
  return pw;
};


/*
 0000000   00000000    0000000    0000000
000   000  000   000  000        000     
000000000  0000000    000  0000  0000000 
000   000  000   000  000   000       000
000   000  000   000   0000000   0000000
 */

nomnom = require("nomnom").script("mpw").options({
  url: {
    position: 0,
    help: "the url of the site",
    required: false
  },
  list: {
    abbr: 'l',
    flag: true,
    help: 'list known sites'
  },
  "delete": {
    abbr: 'd',
    flag: true,
    help: 'delete site(s)'
  },
  stash: {
    abbr: 's',
    flag: true,
    help: 'show stash'
  },
  reset: {
    abbr: 'r',
    flag: true,
    help: 'delete stash'
  },
  version: {
    abbr: 'v',
    flag: true,
    help: "show version",
    hidden: true
  }
});

args = nomnom.parse();


/*
000   000   0000000    0000000  000   000
000   000  000   000  000       000   000
000000000  000000000  0000000   000000000
000   000  000   000       000  000   000
000   000  000   000  0000000   000   000
 */

genHash = function(value) {
  return crypto.createHash('sha512').update(value).digest('hex');
};


/*
 0000000  00000000   000   000  00000000   000000000   0000000 
000       000   000   000 000   000   000     000     000   000
000       0000000      00000    00000000      000     000   000
000       000   000     000     000           000     000   000
 0000000  000   000     000     000           000      0000000
 */

cipherType = 'aes-256-cbc';

fileEncoding = {
  encoding: 'utf8'
};

encrypt = function(data, key) {
  var cipher, enc;
  cipher = crypto.createCipher(cipherType, genHash(key));
  enc = cipher.update(data, 'utf8', 'hex');
  return enc += cipher.final('hex');
};

decrypt = function(data, key) {
  var cipher, dec;
  cipher = crypto.createDecipher(cipherType, genHash(key));
  dec = cipher.update(data, 'hex', 'utf8');
  return dec += cipher.final('utf8');
};

writeBufferToFile = function(data, key, file) {
  var encrypted;
  encrypted = encrypt(data, key);
  return fs.writeFileSync(file, encrypted, fileEncoding);
};

readFromFile = function(key, file, cb) {
  var encrypted;
  if (fs.existsSync(file)) {
    try {
      encrypted = fs.readFileSync(file, fileEncoding);
    } catch (_error) {
      error('can\'t read file at', file);
      return;
    }
    try {
      return cb(decrypt(encrypted, key));
    } catch (_error) {
      return error('can\'t decrypt file', file);
    }
  } else {
    return error('no file at', file);
  }
};


/*
 0000000  000000000   0000000    0000000  000   000
000          000     000   000  000       000   000
0000000      000     000000000  0000000   000000000
     000     000     000   000       000  000   000
0000000      000     000   000  0000000   000   000
 */

writeStash = function() {
  var buf;
  buf = new Buffer(JSON.stringify(stash), "utf8");
  return writeBufferToFile(buf, mstr, stashFile);
};

readStash = function(cb) {
  if (fs.existsSync(stashFile)) {
    return readFromFile(mstr, stashFile, function(json) {
      stash = JSON.parse(json);
      return cb();
    });
  } else {
    stash = {
      configs: {}
    };
    return cb();
  }
};


/*
00000000   00000000   0000000  00000000  000000000
000   000  000       000       000          000   
0000000    0000000   0000000   0000000      000   
000   000  000            000  000          000   
000   000  00000000  0000000   00000000     000
 */

if (args.reset) {
  try {
    fs.unlinkSync(stashFile);
    console.log('...', stashFile, 'removed');
  } catch (_error) {
    console.log('can\'t remove ', stashFile);
  }
  process.exit(0);
}


/*
000   000  00000000  00000000    0000000  000   0000000   000   000
000   000  000       000   000  000       000  000   000  0000  000
 000 000   0000000   0000000    0000000   000  000   000  000 0 000
   000     000       000   000       000  000  000   000  000  0000
    0      00000000  000   000  0000000   000   0000000   000   000
 */

if (args.version) {
  v = '0.0.88'.split('.');
  console.log(bold + BG(0, 0, 1) + fw(23) + " p" + BG(0, 0, 2) + "w" + BG(0, 0, 3) + fw(23) + "m" + fg(1, 1, 5) + " " + fw(23) + BG(0, 0, 4) + " " + BG(0, 0, 5) + fw(23) + " " + v[0] + " " + BG(0, 0, 4) + fg(1, 1, 5) + '.' + BG(0, 0, 3) + fw(23) + " " + v[1] + " " + BG(0, 0, 2) + fg(0, 0, 5) + '.' + BG(0, 0, 1) + fw(23) + " " + v[2] + " ");
  process.exit(0);
}


/*
 0000000   0000000  00000000   00000000  00000000  000   000
000       000       000   000  000       000       0000  000
0000000   000       0000000    0000000   0000000   000 0 000
     000  000       000   000  000       000       000  0000
0000000    0000000  000   000  00000000  00000000  000   000
 */

screen = blessed.screen({
  autoPadding: true,
  smartCSR: true,
  cursorShape: box
});

screen.title = 'mpw';

box = blessed.box({
  parent: screen,
  top: 'center',
  left: 'center',
  width: '90%',
  height: '90%',
  content: fw(6) + '{bold}mpw{/bold} 0.0.88',
  tags: true,
  shadow: true,
  dockBorders: true,
  ignoreDockContrast: true,
  border: {
    type: 'line'
  },
  style: {
    fg: color.text,
    bg: color.bg,
    border: {
      fg: color.border,
      bg: color.bg
    }
  }
});

screen.on('resize', function() {
  return log('resize');
});


/*
000   000  00000000  000   000  00000000   00000000   00000000   0000000   0000000
000  000   000        000 000   000   000  000   000  000       000       000     
0000000    0000000     00000    00000000   0000000    0000000   0000000   0000000 
000  000   000          000     000        000   000  000            000       000
000   000  00000000     000     000        000   000  00000000  0000000   0000000
 */

screen.on('keypress', function(ch, key) {
  if (key.full === 'C-c') {
    process.exit(0);
  }
  if (key.full === 'escape') {
    return process.exit(0);
  }
});


/*
000       0000000    0000000 
000      000   000  000      
000      000   000  000  0000
000      000   000  000   000
0000000   0000000    0000000
 */

log = function() {
  box.setContent(box.content + '\n' + [].slice.call(arguments, 0).join(' ') + reset);
  return screen.render();
};

clr = function() {
  box.setContent(reset);
  return screen.render();
};


/*
00000000  00000000   00000000    0000000   00000000 
000       000   000  000   000  000   000  000   000
0000000   0000000    0000000    000   000  0000000  
000       000   000  000   000  000   000  000   000
00000000  000   000  000   000   0000000   000   000
 */

error = function() {
  var errorBox, errorMessage;
  errorBox = blessed.message({
    top: 'center',
    left: 'center',
    width: '100%',
    height: 5,
    border: {
      type: 'bg'
    },
    style: {
      bg: color.error_bg,
      border: {
        bg: color.error_border
      }
    }
  });
  box.append(errorBox);
  errorMessage = BG(5, 0, 0) + bold + fg(5, 5, 0) + "[ERROR]\n" + reset + bold + fg(5, 3, 0) + arguments[0] + '\n' + fg(5, 5, 0) + [].splice.call(arguments, 1).join('\n') + reset;
  return errorBox.display(errorMessage, 3, function() {
    return process.exit(1);
  });
};


/*
000      000   0000000  000000000
000      000  000          000   
000      000  0000000      000   
000      000       000     000   
0000000  000  0000000      000
 */

listStash = function(hash) {
  var data, editColum, list, selectedConfig, selectedHash, siteKey, url;
  data = [[fw(1) + 'site', 'password', 'pattern', 'seed'], ['', '', '', '']];
  for (siteKey in stash.configs) {
    url = decrypt(stash.configs[siteKey].url, mstr);
    data.push([bold + fg(2, 2, 5) + url + reset, fg(5, 5, 0) + makePassword(genHash(url + mstr), stash.configs[siteKey]) + reset, fw(6) + stash.configs[siteKey].pattern + reset, fw(3) + stash.configs[siteKey].seed + reset]);
  }
  data.push(['', '', '', '']);
  list = blessed.listtable({
    parent: box,
    data: data,
    bottom: 0,
    left: 'center',
    width: '90%',
    height: '50%',
    align: 'left',
    tags: true,
    keys: true,
    noCellBorders: true,
    invertSelected: true,
    padding: {
      left: 2,
      right: 2
    },
    border: {
      type: 'line'
    },
    style: {
      fg: color.text,
      border: {
        fg: color.border,
        bg: color.bg
      },
      cell: {
        fg: 'magenta',
        selected: {
          bg: color.bg
        }
      }
    }
  });
  selectedHash = function() {
    var index;
    index = list.getScroll();
    if (index > 1) {
      return _.keysIn(stash.configs)[index - 2];
    }
  };
  selectedConfig = function() {
    if (hash = selectedHash()) {
      return stash.configs[hash];
    }
  };
  editColum = function(column, cb) {
    var edit, left, text;
    text = list.getItem(list.getScroll()).getText();
    left = _.reduce(list._maxes.slice(0, column), (function(sum, n) {
      return sum + n + 1;
    }), 0);
    edit = blessed.textbox({
      value: text.substr(left, list._maxes[column] - 2),
      parent: list,
      left: left - 1,
      width: list._maxes[column] + 1,
      top: list.getScroll() - 1,
      align: 'center',
      height: 3,
      tags: true,
      keys: true,
      border: {
        type: 'line'
      },
      style: {
        fg: color.text,
        border: {
          fg: color.border
        }
      }
    });
    screen.render();
    edit.on('resize', function() {
      list.remove(edit);
      return screen.render();
    });
    return edit.readInput(function(err, data) {
      list.remove(edit);
      screen.render();
      if ((err == null) && (data != null ? data.length : void 0)) {
        return cb(data);
      }
    });
  };
  list.focus();
  if (hash != null) {
    list.select((_.indexOf(_.keysIn(stash.configs), hash)) + 2);
  }
  screen.render();
  list.on('keypress', function(ch, k) {
    var config, copy, index, key, password, site;
    key = k.full;

    /*
    0000000    00000000  000      00000000  000000000  00000000
    000   000  000       000      000          000     000     
    000   000  0000000   000      0000000      000     0000000 
    000   000  000       000      000          000     000     
    0000000    00000000  0000000  00000000     000     00000000
     */
    if (key === 'backspace') {
      index = list.getScroll();
      if (index > 1) {
        list.removeItem(index);
        site = _.keysIn(stash.configs)[index - 2];
        delete stash.configs[site];
        screen.render();
      }
    }
    if (key === 's') {
      writeStash();
      log('saved');
    }

    /*
    00000000    0000000   000000000  000000000  00000000  00000000   000   000
    000   000  000   000     000        000     000       000   000  0000  000
    00000000   000000000     000        000     0000000   0000000    000 0 000
    000        000   000     000        000     000       000   000  000  0000
    000        000   000     000        000     00000000  000   000  000   000
     */
    if (key === 'p') {
      editColum(2, function(pattern) {
        var config;
        config = selectedConfig();
        config.pattern = pattern;
        newSeed(config);
        writeStash();
        return listStash(selectedHash());
      });
    }
    if (key === 'r') {
      log('reseed');
    }
    if (key === 'n') {
      list.select(_.keysIn(stash.configs).length + 2);
      editColum(0, function(site) {
        return newSite(_.trim(site));
      });
    }
    if (key === 'enter') {
      if (config = selectedConfig()) {
        url = decrypt(config.url, mstr);
        password = makePassword(genHash(url + mstr), config);
        copy = require('copy-paste');
        copy.copy(password);
        return process.exit(0);
      } else {
        return editColum(0, function(site) {
          if (containsLink(site)) {
            return newSite(extractSite(site));
          }
        });
      }
    }
  });
};


/*
000   000  00000000  000   000   0000000  000  000000000  00000000
0000  000  000       000 0 000  000       000     000     000     
000 0 000  0000000   000000000  0000000   000     000     0000000 
000  0000  000       000   000       000  000     000     000     
000   000  00000000  00     00  0000000   000     000     00000000
 */

newSeed = function(config) {
  var salt;
  salt = "";
  while (salt.length < config.pattern.length) {
    salt += bcrypt.genSaltSync(13).substr(10);
  }
  return config.seed = salt.substr(0, config.pattern.length);
};

newSite = function(site) {
  var config, hash, password;
  log(site, mstr);
  config = {};
  config.url = encrypt(site, mstr);
  config.pattern = stash.pattern;
  newSeed(config);
  hash = genHash(site + mstr);
  stash.configs[hash] = config;
  password = makePassword(hash, config);
  writeStash();
  return listStash(hash);
};


/*
000   000  000   000  000       0000000    0000000  000   000
000   000  0000  000  000      000   000  000       000  000 
000   000  000 0 000  000      000   000  000       0000000  
000   000  000  0000  000      000   000  000       000  000 
 0000000   000   000  0000000   0000000    0000000  000   000
 */

unlock = function() {
  var passwordBox;
  passwordBox = blessed.textbox({
    parent: box,
    censor: '●',
    top: 'center',
    left: 'center',
    width: '100%',
    height: 3,
    border: {
      type: 'bg'
    },
    tags: true,
    style: {
      fg: color.password,
      bg: color.password_bg,
      border: {
        bg: color.password_border
      }
    }
  });
  screen.render();
  passwordBox.on('keypress', function(ch, key) {
    if (key.full === 'C-c') {
      return process.exit(0);
    }
  });
  return passwordBox.readInput(function(err, data) {
    if ((err != null) || !(data != null ? data.length : void 0)) {
      process.exit(0);
    }
    box.remove(passwordBox);
    mstr = data;
    return readStash(main);
  });
};

unlock();


/*
00     00   0000000   000  000   000
000   000  000   000  000  0000  000
000000000  000000000  000  000 0 000
000 0 000  000   000  000  000  0000
000   000  000   000  000  000   000
 */

main = function() {
  var clipboard, hash, ref, site;
  if (args._.length === 0) {
    clipboard = require('copy-paste').paste();
    if (containsLink(clipboard)) {
      site = extractSite(clipboard);
    } else {
      listStash();
      return;
    }
  } else {
    site = args._[0];
  }
  if (!stash.pattern) {
    stash.pattern = default_pattern;
  }
  hash = genHash(site + mstr);
  if (((ref = stash.configs) != null ? ref[hash] : void 0) != null) {
    return listStash(hash);
  } else {
    return newSite(site);
  }
};


/*
00000000  000   000  000  000000000
000        000 000   000     000   
0000000     00000    000     000   
000        000 000   000     000   
00000000  000   000  000     000
 */

exit = function() {
  writeStash();
  mstr = 0;
  return process.exit(0);
};


/*
000000000   0000000   0000000     0000000 
   000     000   000  000   000  000   000
   000     000   000  000   000  000   000
   000     000   000  000   000  000   000
   000      0000000   0000000     0000000
 */


/*

- 'nightrider' animation after password enter
- autoclose timeout
- join seed and pattern: full character set patterns
- don't show list fully decrypted by default
 */
