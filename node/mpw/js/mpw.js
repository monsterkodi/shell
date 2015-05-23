var BG, BW, _s, _url, ansi, args, blessed, bold, box, clearBox, clearSeed, clr, color, containsLink, cryptools, decrypt, decryptFile, default_pattern, dirty, drawScreen, editColum, encrypt, error, exit, extractSite, fg, fs, fw, genHash, handleKey, indexOf, isdirty, jsonStr, keysIn, listConfig, listStash, log, main, makePassword, mstr, newSeed, newSite, nomnom, numConfigs, pad, password, path, random, readStash, reduce, reset, screen, sleep, stash, stashFile, trim, undirty, unlock, v, writeStash;

ansi = require('ansi-256-colors');

fs = require('fs');

path = require('path');

_s = require('underscore.string');

_url = require('./coffee/url');

blessed = require('blessed');

password = require('./coffee/password');

cryptools = require('./coffee/cryptools');

sleep = require('sleep');

pad = require('lodash.pad');

trim = require('lodash.trim');

keysIn = require('lodash.keysIn');

reduce = require('lodash.reduce');

indexOf = require('lodash.indexOf');

random = require('lodash.random');

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

default_pattern = 'abcd+efgh+12';


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
        if (err[0] === 'can\'t decrypt file') {
          stash = void 0;
          return cb();
        } else {
          return error.apply(this, err);
        }
      } else {
        stash = JSON.parse(json);
        undirty();
        return cb();
      }
    });
  } else {
    stash = {
      pattern: default_pattern,
      autoclose: 20,
      decryptall: false,
      seed: false,
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
  v = '0.0.623'.split('.');
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
  content: fw(6) + '{bold}mpw{/bold} 0.0.623',
  tags: true,
  dockBorders: true,
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

drawScreen = function(ms) {
  screen.draw(0, screen.lines.length - 1);
  screen.program.flush();
  return sleep.usleep(ms * 1000);
};

clearBox = function(id) {
  var child, j, len, ref, results;
  ref = box.children;
  results = [];
  for (j = 0, len = ref.length; j < len; j++) {
    child = ref[j];
    if (child.id === id) {
      results.push(box.remove(child));
    } else {
      results.push(void 0);
    }
  }
  return results;
};


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

handleKey = function(key) {
  switch (key) {
    case 's':
      return writeStash();
    case 'C-c':
    case 'escape':
      return process.exit(0);
  }
};


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
00000000  0000000    000  000000000   0000000   0000000   000    
000       000   000  000     000     000       000   000  000    
0000000   000   000  000     000     000       000   000  000    
000       000   000  000     000     000       000   000  000    
00000000  0000000    000     000      0000000   0000000   0000000
 */

editColum = function(list, column, cb) {
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
000      000   0000000  000000000
000      000  000          000   
000      000  0000000      000   
000      000       000     000   
0000000  000  0000000      000
 */

listStash = function(hash) {
  var config, createSite, data, editPattern, list, selectedConfig, selectedHash, siteKey, url;
  data = [[fw(1) + 'site', 'password', 'pattern', 'seed'], ['', '', '', '']];
  for (siteKey in stash.configs) {
    config = stash.configs[siteKey];
    url = decrypt(config.url, mstr);
    data.push([bold + fg(2, 2, 5) + url + reset, fg(5, 5, 0) + makePassword(genHash(url + mstr), config) + reset, fw(6) + (config.pattern === stash.pattern && ' ' || config.pattern) + reset, fw(3) + (trim(config.seed).length && '✓' || '') + reset]);
  }
  data.push(['', '', '', '']);
  clearBox('stash');
  list = blessed.listtable({
    id: 'stash',
    parent: box,
    data: data,
    top: 'center',
    left: 'center',
    width: '80%',
    height: '80%',
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
  00000000    0000000   000000000  000000000  00000000  00000000   000   000
  000   000  000   000     000        000     000       000   000  0000  000
  00000000   000000000     000        000     0000000   0000000    000 0 000
  000        000   000     000        000     000       000   000  000  0000
  000        000   000     000        000     00000000  000   000  000   000
   */
  editPattern = function() {
    return editColum(list, 2, function(pattern) {
      if (password.isValidPattern(pattern)) {
        config = selectedConfig();
        config.pattern = pattern;
        clearSeed(config);
        dirty();
        return listStash(selectedHash());
      }
    });
  };
  createSite = function() {
    list.select(numConfigs() + 2);
    return editColum(list, 0, function(site) {
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
    var copy, index, key, ref, site;
    key = k.full;
    switch (key) {
      case 'backspace':

        /*
        0000000    00000000  000      00000000  000000000  00000000
        000   000  000       000      000          000     000     
        000   000  0000000   000      0000000      000     0000000 
        000   000  000       000      000          000     000     
        0000000    00000000  0000000  00000000     000     00000000
         */
        index = list.getScroll();
        if (index > 1) {
          list.removeItem(index);
          site = keysIn(stash.configs)[index - 2];
          delete stash.configs[site];
          return dirty();
        }
        break;
      case 'r':
        hash = selectedHash();
        return readStash(function() {
          return listStash(hash);
        });
      case 'p':
        if (selectedConfig()) {
          return editPattern();
        }
        break;
      case '/':
        if (config = selectedConfig()) {
          newSeed(config);
          dirty();
          return listStash(selectedHash());
        }
        break;
      case '.':
        if (config = selectedConfig()) {
          clearSeed(config);
          dirty();
          return listStash(selectedHash());
        }
        break;
      case 'n':
        return createSite();
      case ',':
        return listConfig();
      case 'enter':

        /*
        00000000  000   000  000000000  00000000  00000000 
        000       0000  000     000     000       000   000
        0000000   000 0 000     000     0000000   0000000  
        000       000  0000     000     000       000   000
        00000000  000   000     000     00000000  000   000
         */
        if ((isdirty == null) && (config = selectedConfig())) {
          url = decrypt(config.url, mstr);
          copy = require('copy-paste');
          copy.copy(makePassword(genHash(url + mstr), config));
          return process.exit(0);
        } else {
          if ((ref = list.getScroll()) === 0 || ref === 1 || ref === (numConfigs() + 2)) {
            return createSite();
          } else {
            return editPattern();
          }
        }
        break;
      default:
        return handleKey(key);
    }
  });
};


/*
 0000000   0000000   000   000  00000000  000   0000000 
000       000   000  0000  000  000       000  000      
000       000   000  000 0 000  000000    000  000  0000
000       000   000  000  0000  000       000  000   000
 0000000   0000000   000   000  000       000   0000000
 */

listConfig = function(index) {
  var c, cfg, close, data, j, len, list, value;
  cfg = [['default pattern', 'pattern', 'string'], ['auto close delay in ms', 'autoclose', 'int'], ['seed new sites', 'seed', 'bool'], ['show decrypted list', 'decryptall', 'bool']];
  data = [[fw(1) + 'setting', 'value'], ['', '']];
  for (j = 0, len = cfg.length; j < len; j++) {
    c = cfg[j];
    switch (c[2]) {
      case 'bool':
        value = stash[c[1]] && '✓' || '❌';
        break;
      case 'int':
        value = String(stash[c[1]]);
        break;
      default:
        value = stash[c[1]];
    }
    data.push([bold + fw(6) + c[0] + reset, fg(5, 5, 0) + value + reset]);
  }
  clearBox('config');
  list = blessed.listtable({
    id: 'config',
    parent: box,
    data: data,
    top: 'center',
    left: 'center',
    width: '80%',
    height: '80%',
    align: 'left',
    tags: true,
    keys: true,
    noCellBorders: true,
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
  close = function() {
    clearBox('config');
    return listStash();
  };
  list.on('keypress', function(ch, k) {
    var key;
    key = k.full;
    switch (key) {
      case 'escape':
        return close();
      case 'enter':
        if (list.getScroll() === 1) {
          return close();
        } else {
          index = list.getScroll() - 2;
          if (cfg[index][2] === 'bool') {
            stash[cfg[index][1]] = !stash[cfg[index][1]];
            dirty();
            return listConfig(index);
          } else {
            return editColum(list, 1, function(value) {
              stash[cfg[index][1]] = value;
              dirty();
              return listConfig(index);
            });
          }
        }
        break;
      case 'space':
      case 'left':
      case 'right':
        index = list.getScroll() - 2;
        if (cfg[index][2] === 'bool') {
          stash[cfg[index][1]] = !stash[cfg[index][1]];
          dirty();
          return listConfig(index);
        }
        break;
      default:
        return handleKey(key);
    }
  });
  if (index != null) {
    list.select(index + 2);
  }
  list.focus();
  return screen.render();
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

makePassword = function(hash, config) {
  return password.make(hash, config.pattern, config.seed);
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
      process.exit(0);
    }
    if (key.full === 'escape') {
      return process.exit(0);
    }
  });
  return passwordBox.readInput(function(err, data) {
    var value;
    if (err != null) {
      process.exit(0);
    }
    mstr = data;
    value = pad('', passwordBox.value.length, '●');
    while (passwordBox.content.length <= passwordBox.width) {
      passwordBox.setContent(passwordBox.content + '●');
      passwordBox.render();
      drawScreen(2);
    }
    drawScreen(20);
    box.remove(passwordBox);
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
  if (stash == null) {
    unlock();
    return;
  }
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

- config:
    default pattern
    always add seed
    auto close time
    fully decrypted
 */
