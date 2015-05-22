var BG, BW, _s, _url, ansi, args, blessed, bold, box, clearSeed, clr, color, containsLink, cryptools, decrypt, decryptFile, default_pattern, dirty, encrypt, error, exit, extractSite, fg, fs, fw, genHash, indexOf, isdirty, jsonStr, keysIn, listStash, log, main, mstr, newSeed, newSite, nomnom, numConfigs, pad, password, path, readStash, reduce, reset, screen, stash, stashFile, trim, undirty, unlock, v, writeStash,
  indexOf1 = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

ansi = require('ansi-256-colors');

fs = require('fs');

path = require('path');

_s = require('underscore.string');

_url = require('./coffee/url');

blessed = require('blessed');

password = require('./coffee/password');

cryptools = require('./coffee/cryptools');

pad = require('lodash.pad');

trim = require('lodash.trim');

keysIn = require('lodash.keysIn');

reduce = require('lodash.reduce');

indexOf = require('lodash.indexOf');

genHash = cryptools.genHash;

encrypt = cryptools.encrypt;

decrypt = cryptools.decrypt;

decryptFile = cryptools.decryptFile;

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
  error_border: '#ff8800',
  dirty: '#ff8800'
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

default_pattern = 'aaaa-aaa-aaaa|0000';


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
  },
  password: {
    abbr: 'pw',
    help: "use this as master password",
    hidden: true
  },
  stash: {
    help: "open this stash",
    hidden: true
  }
});

args = nomnom.parse();

stashFile = args.stash || process.env.HOME + '/.config/mpw.stash';

mstr = args.password || void 0;

stash = {};


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
  cryptools.encryptFile(stashFile, buf, mstr);
  return undirty();
};

readStash = function(cb) {
  if (fs.existsSync(stashFile)) {
    return decryptFile(stashFile, mstr, function(err, json) {
      if (err != null) {
        return error.apply(this, err);
      } else {
        stash = JSON.parse(json);
        undirty();
        return cb();
      }
    });
  } else {
    stash = {
      configs: {}
    };
    undirty();
    return cb();
  }
};

numConfigs = function() {
  return keysIn(stash.configs).length;
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
  v = '0.0.271'.split('.');
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
  cursorShape: box,
  resizeTimeout: 100,
  artificialCursor: true
});

screen.title = 'mpw';

box = blessed.box({
  parent: screen,
  top: 'center',
  left: 'center',
  width: '90%',
  height: '90%',
  content: fw(6) + '{bold}mpw{/bold} 0.0.271',
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
0000000    000  00000000   000000000  000   000
000   000  000  000   000     000      000 000 
000   000  000  0000000       000       00000  
000   000  000  000   000     000        000   
0000000    000  000   000     000        000
 */

isdirty = void 0;

dirty = function() {
  if (isdirty == null) {
    isdirty = blessed.element({
      parent: box,
      content: '▣',
      right: 1,
      top: 0,
      width: 1,
      height: 1,
      fg: color.dirty,
      bg: color.bg
    });
  }
  return screen.render();
};

undirty = function() {
  if (isdirty != null) {
    box.remove(isdirty);
    isdirty = void 0;
    return screen.render();
  }
};


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
  var createSite, data, editColum, editPattern, list, selectedConfig, selectedHash, siteKey, url;
  data = [[fw(1) + 'site', 'password', 'pattern', 'seed'], ['', '', '', '']];
  for (siteKey in stash.configs) {
    url = decrypt(stash.configs[siteKey].url, mstr);
    data.push([bold + fg(2, 2, 5) + url + reset, fg(5, 5, 0) + password.make(genHash(url + mstr), stash.configs[siteKey]) + reset, fw(6) + stash.configs[siteKey].pattern + reset, fw(3) + stash.configs[siteKey].seed + reset]);
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
      return keysIn(stash.configs)[index - 2];
    }
  };
  selectedConfig = function() {
    if (hash = selectedHash()) {
      return stash.configs[hash];
    }
  };

  /*
  00000000  0000000    000  000000000   0000000   0000000   000    
  000       000   000  000     000     000       000   000  000    
  0000000   000   000  000     000     000       000   000  000    
  000       000   000  000     000     000       000   000  000    
  00000000  0000000    000     000      0000000   0000000   0000000
   */
  editColum = function(column, cb) {
    var edit, left, text;
    text = list.getItem(list.getScroll()).getText();
    left = reduce(list._maxes.slice(0, column), (function(sum, n) {
      return sum + n + 1;
    }), 0);
    edit = blessed.textbox({
      value: trim(text.substr(left, list._maxes[column] - 2)),
      parent: list,
      left: left - 1,
      width: list._maxes[column] + 1,
      top: list.getScroll() - 1,
      align: 'left',
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
    edit.on('keypress', function(ch, k) {
      var key;
      key = k.full;
      if (key === 'left') {
        return screen;
      }
    });
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

  /*
  00000000    0000000   000000000  000000000  00000000  00000000   000   000
  000   000  000   000     000        000     000       000   000  0000  000
  00000000   000000000     000        000     0000000   0000000    000 0 000
  000        000   000     000        000     000       000   000  000  0000
  000        000   000     000        000     00000000  000   000  000   000
   */
  editPattern = function() {
    return editColum(2, function(pattern) {
      var config;
      config = selectedConfig();
      if (indexOf1.call(pattern, '$') >= 0) {
        url = decrypt(config.url, mstr);
        url = url.split('.')[0];
        pattern = pattern.replace('$', url);
      }
      config.pattern = pattern;
      clearSeed(config);
      dirty();
      return listStash(selectedHash());
    });
  };
  createSite = function() {
    list.select(numConfigs() + 2);
    return editColum(0, function(site) {
      return newSite(site);
    });
  };
  list.focus();
  if (hash != null) {
    list.select((indexOf(keysIn(stash.configs), hash)) + 2);
  }
  screen.render();

  /*
  000   000  00000000  000   000   0000000
  000  000   000        000 000   000     
  0000000    0000000     00000    0000000 
  000  000   000          000          000
  000   000  00000000     000     0000000
   */
  list.on('keypress', function(ch, k) {
    var config, copy, index, key, ref, site;
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
        site = keysIn(stash.configs)[index - 2];
        delete stash.configs[site];
        dirty();
      }
    }
    if (key === 's') {
      writeStash();
      log('saved');
    }
    if (key === 'p') {
      if (selectedConfig()) {
        editPattern();
      }
    }
    if (key === 'r') {
      hash = selectedHash();
      readStash(function() {
        return listStash(hash);
      });
    }
    if (key === '/') {
      if (config = selectedConfig()) {
        newSeed(config);
        dirty();
        listStash(selectedHash());
      }
    }
    if (key === '.') {
      if (config = selectedConfig()) {
        clearSeed(config);
        dirty();
        listStash(selectedHash());
      }
    }
    if (key === 'n') {
      createSite();
    }

    /*
    00000000  000   000  000000000  00000000  00000000 
    000       0000  000     000     000       000   000
    0000000   000 0 000     000     0000000   0000000  
    000       000  0000     000     000       000   000
    00000000  000   000     000     00000000  000   000
     */
    if (key === 'enter') {
      if ((isdirty == null) && (config = selectedConfig())) {
        url = decrypt(config.url, mstr);
        copy = require('copy-paste');
        copy.copy(password.make(genHash(url + mstr), config));
        return process.exit(0);
      } else {
        if ((ref = list.getScroll()) === 0 || ref === 1 || ref === (numConfigs() + 2)) {
          return createSite();
        } else {
          return editPattern();
        }
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
  return config.seed = cryptools.genSalt(config.pattern.length);
};

clearSeed = function(config) {
  return config.seed = pad('', config.pattern.length, ' ');
};

newSite = function(site) {
  var config, hash;
  if (site == null) {
    return;
  }
  site = trim(site);
  if (site.length === 0) {
    return;
  }
  config = {};
  config.url = encrypt(site, mstr);
  config.pattern = stash.pattern;
  clearSeed(config);
  hash = genHash(site + mstr);
  stash.configs[hash] = config;
  dirty();
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

if (mstr != null) {
  readStash(main);
} else {
  unlock();
}


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
- don't show list fully decrypted by default
- config:
    default pattern
    always add seed
 */
