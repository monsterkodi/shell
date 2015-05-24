var BG, BW, _s, _url, ansi, args, autoClose, blessed, bold, box, clearBox, clearSeed, clock, clockCount, clockDisplay, clockTick, clockTimer, clr, color, containsLink, copy, cryptools, decrypt, decryptFile, default_pattern, dirty, drawScreen, editColum, encrypt, error, exit, extractSite, fg, fill, fs, fw, genHash, handleKey, indexOf, isdirty, jsonStr, keysIn, listConfig, listStash, lock, log, main, makePassword, mstr, newSeed, newSite, noAutoClose, nomnom, numConfigs, pad, password, path, random, readStash, reduce, reset, screen, sleep, stash, stashFile, stopClock, trim, undirty, unlock, v, writeStash;

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

copy = require('copy-paste');

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
      seed: true,
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
  v = '0.1.127'.split('.');
  console.log(bold + BG(0, 0, 1) + fw(23) + " m" + BG(0, 0, 2) + "p" + BG(0, 0, 3) + fw(23) + "w" + fg(1, 1, 5) + " " + fw(23) + BG(0, 0, 4) + " " + BG(0, 0, 5) + fw(23) + " " + v[0] + " " + BG(0, 0, 4) + fg(1, 1, 5) + '.' + BG(0, 0, 3) + fw(23) + " " + v[1] + " " + BG(0, 0, 2) + fg(0, 0, 5) + '.' + BG(0, 0, 1) + fw(23) + " " + v[2] + " ");
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
  artificialCursor: true,
  style: {
    fg: color.text,
    bg: color.bg
  }
});

screen.title = 'mpw';

fill = blessed.box({
  parent: screen,
  top: 0,
  left: 0,
  right: 0,
  bottom: 0,
  style: {
    bg: 'black'
  }
});

box = blessed.box({
  parent: fill,
  top: 'center',
  left: 'center',
  width: '90%',
  height: '90%',
  content: fw(6) + ' {bold}mpw{/bold} ' + fw(3) + '0.1.127',
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

drawScreen = function(ms) {
  screen.draw(0, screen.lines.length - 1);
  screen.program.flush();
  return sleep.usleep(ms * 1000);
};


/*
 0000000  000      00000000   0000000   00000000   0000000     0000000   000   000
000       000      000       000   000  000   000  000   000  000   000   000 000 
000       000      0000000   000000000  0000000    0000000    000   000    00000  
000       000      000       000   000  000   000  000   000  000   000   000 000 
 0000000  0000000  00000000  000   000  000   000  0000000     0000000   000   000
 */

clearBox = function(id) {
  var child, j, len, ref, results, results1;
  if (id != null) {
    ref = box.children;
    results = [];
    for (j = 0, len = ref.length; j < len; j++) {
      child = ref[j];
      if (child.id === id) {
        log('removed');
        results.push(box.remove(child));
      } else {
        results.push(void 0);
      }
    }
    return results;
  } else {
    results1 = [];
    while (box.children.length) {
      results1.push(box.remove(box.children[0]));
    }
    return results1;
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
      return exit();
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
  noAutoClose();
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
      bg: 'black',
      border: {
        fg: color.border,
        bg: 'black'
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
    if (err == null) {
      autoClose();
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
  var config, createSite, data, editPattern, list, pat, pcol, pwd, selectedConfig, selectedHash, siteKey, url;
  data = [[fw(1) + 'site', 'password', 'pattern', 'seed'], ['', '', '', '']];
  for (siteKey in stash.configs) {
    config = stash.configs[siteKey];
    url = decrypt(config.url, mstr);
    pwd = (stash.decryptall || hash === siteKey) && makePassword(genHash(url + mstr), config) || '';
    pcol = hash === siteKey && fg(5, 5, 0) || fw(15);
    pat = config.pattern === stash.pattern && ' ' || (stash.decryptall && config.pattern || '✓');
    data.push([bold + fg(2, 2, 5) + url + reset, pcol + pwd + reset, fw(6) + pat + reset, fw(3) + (trim(config.seed).length && '✓' || '') + reset]);
  }
  data.push(['', '', '', '']);
  clearBox('stash');
  if (hash != null) {
    config = stash.configs[hash];
    url = decrypt(config.url, mstr);
    copy.copy(makePassword(genHash(url + mstr), config));
  } else {
    copy.copy('');
  }
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
    invertSelected: false,
    padding: {
      left: 2,
      right: 2
    },
    border: {
      type: 'line'
    },
    style: {
      fg: color.text,
      bg: 'black',
      border: {
        fg: color.border,
        bg: color.bg
      },
      cell: {
        fg: 'magenta',
        selected: {
          fg: 'brightwhite',
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
      pattern = trim(pattern);
      if (pattern.length === 0) {
        pattern = stash.pattern;
      }
      if (!password.isValidPattern(pattern)) {
        pattern = stash.pattern;
      }
      config = selectedConfig();
      config.pattern = pattern;
      clearSeed(config);
      dirty();
      return listStash(selectedHash());
    });
  };
  createSite = function() {
    list.select(numConfigs() + 2);
    return editColum(list, 0, function(site) {
      return newSite(site);
    });
  };
  list.on('select', function() {
    if (selectedHash() != null) {
      listStash(selectedHash());
    }
    return autoClose();
  });
  list.on('scroll', function() {
    return autoClose();
  });
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
    var index, key, ref, site;
    autoClose();
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
        if ((ref = list.getScroll()) === 0 || ref === 1) {
          return listConfig();
        } else if (list.getScroll() === numConfigs() + 2) {
          return createSite();
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
  var c, cfg, close, data, j, len, list, value, vcol;
  cfg = [['default pattern', 'pattern', 'string'], ['auto close delay', 'autoclose', 'int'], ['seed new sites', 'seed', 'bool'], ['show all passwords', 'decryptall', 'bool']];
  data = [[fw(1) + 'setting', 'value'], ['', '']];
  for (j = 0, len = cfg.length; j < len; j++) {
    c = cfg[j];
    vcol = fg(5, 5, 0);
    switch (c[2]) {
      case 'bool':
        if (stash[c[1]]) {
          vcol = fg(0, 3, 0);
          value = '✓';
        } else {
          value = '❌';
        }
        break;
      case 'int':
        value = String(stash[c[1]]);
        vcol = fg(2, 2, 5);
        break;
      default:
        value = stash[c[1]];
    }
    data.push([bold + fw(9) + c[0] + reset, vcol + value + reset]);
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
    invertSelected: false,
    padding: {
      left: 2,
      right: 2
    },
    border: {
      type: 'line'
    },
    style: {
      fg: color.text,
      bg: 'black',
      border: {
        fg: color.border,
        bg: color.bg
      },
      cell: {
        selected: {
          fg: 'brightwhite',
          bg: color.bg
        }
      }
    }
  });
  close = function() {
    clearBox('config');
    return listStash();
  };
  list.on('select', function() {
    return autoClose();
  });
  list.on('keypress', function(ch, k) {
    var cfgIndex, key;
    autoClose();
    key = k.full;
    cfgIndex = index || list.getScroll() - 2;
    switch (key) {
      case 'escape':
      case ',':
        return close();
      case 'enter':
        if (list.getScroll() === 1) {
          return close();
        } else {
          if (cfg[cfgIndex][2] === 'bool') {
            stash[cfg[cfgIndex][1]] = !stash[cfg[cfgIndex][1]];
            dirty();
            return listConfig(index);
          } else {
            return editColum(list, 1, function(value) {
              if (cfg[cfgIndex][2] === 'int') {
                value = parseInt(value);
              }
              stash[cfg[cfgIndex][1]] = value;
              dirty();
              return listConfig(cfgIndex);
            });
          }
        }
        break;
      case 'space':
      case 'left':
      case 'right':
        if (cfg[cfgIndex][2] === 'bool') {
          stash[cfg[cfgIndex][1]] = !stash[cfg[cfgIndex][1]];
          dirty();
          return listConfig(cfgIndex);
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
  if (stash.seed) {
    newSeed(config);
  } else {
    clearSeed(config);
  }
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
  passwordBox.on('keypress', function(ch, k) {
    var key;
    key = k.full;
    if (key !== 's') {
      return handleKey(k.full);
    }
  });
  return passwordBox.readInput(function(err, data) {
    var value;
    if (err != null) {
      process.exit(1);
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

lock = function() {
  if (typeof isdirty !== "undefined" && isdirty !== null) {
    return;
  }
  clearBox();
  screen.render();
  mstr = void 0;
  stash = void 0;
  copy.copy('');
  return unlock();
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
    isdirty = true;
    stopClock('◉');
  }
  return screen.render();
};

undirty = function() {
  if (isdirty != null) {
    isdirty = void 0;
    screen.render();
    return autoClose();
  }
};


/*
 0000000  000       0000000    0000000  000   000
000       000      000   000  000       000  000 
000       000      000   000  000       0000000  
000       000      000   000  000       000  000 
 0000000  0000000   0000000    0000000  000   000
 */

noAutoClose = function() {
  return stopClock();
};

autoClose = function() {
  if (isdirty != null) {
    stopClock('◉');
    return;
  }
  if (stash.autoclose > 0) {
    return clock(stash.autoclose);
  }
};

clockTimer = void 0;

clockDisplay = void 0;

clockCount = 0;

clock = function(seconds) {
  clockCount = seconds;
  if (clockDisplay == null) {
    clockDisplay = blessed.element({
      parent: box,
      top: 0,
      right: 1,
      height: 1,
      width: 2,
      fg: color.dirty,
      bg: color.bg,
      align: 'right',
      tags: true,
      style: {
        fg: color.password,
        bg: color.password_bg
      }
    });
  }
  return clockTick();
};

clockTick = function() {
  if (clockDisplay == null) {
    return;
  }
  if (clockCount > 0) {
    if (clockCount >= 10) {
      clockDisplay.content = (clockCount > 20 && fw(6) || fg(4, 2, 0)) + ['▖', '▗', '▝', '▘'][clockCount % 4];
    } else {
      clockDisplay.content = bold + fg(5, 3, 0) + String(clockCount);
    }
    clockCount -= 1;
    if (clockTimer == null) {
      clockTimer = setInterval(clockTick, 1000);
    }
    return screen.render();
  } else {
    clearInterval(clockTimer);
    clockTimer = void 0;
    box.remove(clockDisplay);
    clockDisplay = void 0;
    return lock();
  }
};

stopClock = function(reason) {
  if (clockTimer) {
    clearInterval(clockTimer);
    clockTimer = void 0;
  }
  clockDisplay.content = reason || '▣';
  return screen.render();
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
  autoClose();
  if (args._.length === 0) {
    clipboard = copy.paste();
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
 */
