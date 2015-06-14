var _url, clearSeed, clipboard, containsLink, cryptools, decrypt, decryptFile, default_pattern, dirty, encrypt, error, extractSite, fs, genHash, jsonStr, listStash, main, makePassword, masterChanged, mstr, newSeed, newSite, numConfigs, pad, password, readStash, stash, stashFile, trim, undirty, win, writeStash;

win = (require('remote')).getCurrentWindow();

fs = require('fs');

clipboard = require('clipboard');

_url = require('./js/coffee/urltools');

password = require('./js/coffee/password');

cryptools = require('./js/coffee/cryptools');

trim = require('lodash.trim');

pad = require('lodash.pad');

genHash = cryptools.genHash;

encrypt = cryptools.encrypt;

decrypt = cryptools.decrypt;

decryptFile = cryptools.decryptFile;

extractSite = _url.extractSite;

containsLink = _url.containsLink;

jsonStr = function(a) {
  return JSON.stringify(a, null, " ");
};

error = function() {
  return alert(arguments);
};

mstr = void 0;

default_pattern = 'abcd+efgh+12';

masterChanged = function() {
  mstr = $("master").value;
  return console.log('master changed:' + mstr);
};

document.observe('dom:loaded', function() {
  var clip;
  $("master").focus();
  $("master").on('input', masterChanged);
  clip = clipboard.readText();
  if (containsLink(clip)) {
    return $("site").value = extractSite(clip);
  }
});

win.on('focus', function(event) {
  return $("master").focus();
});

document.on('keydown', function(event) {
  if (event.which === 27) {
    win.hide();
  }
  if (event.which === 13) {
    while ($("master").value.length < 20) {
      $("master").value += 'x';
    }
    console.log('readStash');
    return readStash(main);
  }
});

undirty = function() {
  return console.log('undirty');
};

dirty = function() {
  return console.log('dirty');
};


/*
 0000000  000000000   0000000    0000000  000   000
000          000     000   000  000       000   000
0000000      000     000000000  0000000   000000000
     000     000     000   000       000  000   000
0000000      000     000   000  0000000   000   000
 */

stashFile = process.env.HOME + '/.config/pwm.stash';

stash = {};

writeStash = function() {
  var buf;
  buf = new Buffer(JSON.stringify(stash), "utf8");
  cryptools.encryptFile(stashFile, buf, mstr);
  return undirty();
};

readStash = function(cb) {
  if (fs.existsSync(stashFile)) {
    console.log('stash exists' + stashFile + ' ' + mstr);
    return decryptFile(stashFile, mstr, function(err, json) {
      if (err != null) {
        if (err[0] === 'can\'t decrypt file') {
          console.log('err[0]' + err);
          stash = void 0;
          return cb();
        } else {
          console.log('err' + err);
          return error.apply(this, err);
        }
      } else {
        stash = JSON.parse(json);
        stash.decryptall = false;
        undirty();
        return cb();
      }
    });
  } else {
    stash = {
      pattern: default_pattern,
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
  console.log("hash:" + hash + "config:" + jsonStr(config));
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

listStash = function(hash) {
  var config, data, pass, pat, pwd, siteKey, url;
  data = [['site', 'password', 'pattern', 'seed'], ['', '', '', '']];
  for (siteKey in stash.configs) {
    config = stash.configs[siteKey];
    url = decrypt(config.url, mstr);
    pwd = (stash.decryptall || hash === siteKey) && makePassword(genHash(url + mstr), config) || '';
    pat = config.pattern === stash.pattern && ' ' || (stash.decryptall && config.pattern || '✓');
    data.push([url, pwd, pat, trim(config.seed).length && '✓' || '']);
  }
  data.push(['', '', '', '']);
  if (hash != null) {
    config = stash.configs[hash];
    url = decrypt(config.url, mstr);
    pass = makePassword(genHash(url + mstr), config);
    clipboard.writeText(pass);
    console.log(pass);
    $("password").value = pass;
    $("password").focus();
  } else {
    clipboard.clear();
    $("password").value = "?";
  }
  return console.log(data);
};


/*
00     00   0000000   000  000   000
000   000  000   000  000  0000  000
000000000  000000000  000  000 0 000
000 0 000  000   000  000  000  0000
000   000  000   000  000  000   000
 */

main = function() {
  var hash, ref, site;
  if (stash == null) {
    $("site").value = "no stash: " + mstr;
    return;
  }
  if (containsLink(clipboard.readText())) {
    $("site").value = extractSite(clipboard.readText());
  }
  site = trim($("site").value);
  console.log('site: ' + site + 'mstr: ' + mstr);
  if ((site == null) || site.length === 0) {
    $("password").value = "";
  }
  $("site").focus();
  hash = genHash(site + mstr);
  if (((ref = stash.configs) != null ? ref[hash] : void 0) != null) {
    return listStash(hash);
  } else {
    return newSite(site);
  }
};
