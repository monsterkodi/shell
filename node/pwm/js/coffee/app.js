
/*
 0000000   00000000   00000000 
000   000  000   000  000   000
000000000  00000000   00000000 
000   000  000        000      
000   000  000        000
 */
var _url, clearSeed, clipboard, containsLink, cryptools, decrypt, decryptFile, dirty, encrypt, error, extractDomain, extractSite, fs, genHash, jsonStr, knix, log, main, makePassword, masterBlurred, masterChanged, masterFocus, mstr, newSeed, newSite, numConfigs, pad, password, passwordBlurred, passwordFocus, pattern, readStash, setSite, showPassword, siteBlurred, siteChanged, siteFocus, stash, stashFile, trim, undirty, updateSitePassword, win, writeStash;

trim = require('lodash.trim');

pad = require('lodash.pad');

fs = require('fs');

clipboard = require('clipboard');

_url = require('./js/coffee/tools/urltools');

password = require('./js/coffee/tools/password');

cryptools = require('./js/coffee/tools/cryptools');

knix = require('./js/coffee/knix/knix');

log = (require('./js/coffee/tools/log')).log;

win = (require('remote')).getCurrentWindow();

genHash = cryptools.genHash;

encrypt = cryptools.encrypt;

decrypt = cryptools.decrypt;

decryptFile = cryptools.decryptFile;

extractSite = _url.extractSite;

extractDomain = _url.extractDomain;

containsLink = _url.containsLink;

jsonStr = function(a) {
  return JSON.stringify(a, null, " ");
};

error = function() {
  return alert(arguments);
};

mstr = void 0;

stash = {};

stashFile = process.env.HOME + '/.config/pwm.stash';

pattern = 'abcd+efgh+12';

masterChanged = function() {
  mstr = $("master").value;
  $("master-ghost").setStyle({
    opacity: (mstr != null ? mstr.length : void 0) ? 0 : 1
  });
  return updateSitePassword($("site").value);
};

masterFocus = function() {
  return $("master-border").addClassName('focus');
};

masterBlurred = function() {
  var results;
  $("master-border").removeClassName('focus');
  if ($("master").value.length) {
    results = [];
    while ($("master").value.length < 18) {
      results.push($("master").value += 'x');
    }
    return results;
  }
};

siteFocus = function() {
  return $("site-border").addClassName('focus');
};

siteBlurred = function() {
  return $("site-border").removeClassName('focus');
};

passwordFocus = function() {
  return $("password-border").addClassName('focus');
};

passwordBlurred = function() {
  return $("password-border").removeClassName('focus');
};

setSite = function(site) {
  $("site").value = site;
  return siteChanged();
};

siteChanged = function() {
  $("site-ghost").setStyle({
    opacity: $("site").value.length ? 0 : 1
  });
  return updateSitePassword($("site").value);
};

document.observe('dom:loaded', function() {
  var domain;
  knix.init({
    console: true
  });
  $("master").on('focus', masterFocus);
  $("master").on('blur', masterBlurred);
  $("site").on('focus', siteFocus);
  $("site").on('blur', siteBlurred);
  $("password").on('focus', passwordFocus);
  $("password").on('blur', passwordBlurred);
  $("master").on('input', masterChanged);
  $("site").on('input', siteChanged);
  $("master").focus();
  if (domain = extractDomain(clipboard.readText())) {
    return setSite(domain);
  }
});

win.on('focus', function(event) {
  var domain;
  if ((mstr != null) && mstr.length) {
    if (domain = extractDomain(clipboard.readText())) {
      setSite(domain);
      clipboard.writeText($("password").value);
      return $("password").focus();
    } else {
      $("site").focus();
      return $("site").setSelectionRange(0, $("site").value.length);
    }
  } else {
    return $("master").focus();
  }
});

document.on('keydown', function(event) {
  if (event.which === 27) {
    win.hide();
  }
  if (event.which === 13) {
    return readStash(main);
  }
});

undirty = function() {
  return log('undirty');
};

dirty = function() {
  return log('dirty');
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
  cryptools.encryptFile(stashFile, buf, mstr);
  return undirty();
};

readStash = function(cb) {
  if (fs.existsSync(stashFile)) {
    log('stash exists' + stashFile + ' ' + mstr);
    return decryptFile(stashFile, mstr, function(err, json) {
      if (err != null) {
        if (err[0] === 'can\'t decrypt file') {
          log('err[0]' + err);
          stash = void 0;
          return cb();
        } else {
          log('err' + err);
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
      pattern: pattern,
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
  log("hash:" + hash + "config:" + jsonStr(config));
  return password.make(hash, config.pattern, config.seed);
};

newSite = function(site) {
  var pass;
  pass = updateSitePassword(site);
  clipboard.writeText(pass);
  dirty();
  return $("password").focus();
};

updateSitePassword = function(site) {
  var config, hash, pass;
  site = trim(site);
  if (!(site != null ? site.length : void 0) || !(mstr != null ? mstr.length : void 0)) {
    $("password").value = "";
    $("password-ghost").setStyle({
      opacity: 1
    });
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
  return pass = showPassword(config);
};

showPassword = function(config) {
  var pass, url;
  url = decrypt(config.url, mstr);
  pass = makePassword(genHash(url + mstr), config);
  log("pass", pass);
  $("password").value = pass;
  $("password-ghost").setStyle({
    opacity: 0
  });
  return pass;
};


/*
00     00   0000000   000  000   000
000   000  000   000  000  0000  000
000000000  000000000  000  000 0 000
000 0 000  000   000  000  000  0000
000   000  000   000  000  000   000
 */

main = function() {
  var hash, pass, ref, site;
  if (stash == null) {
    $("site").value = "no stash: " + stashFile;
    return;
  }
  site = trim($("site").value);
  log('site:', site, 'mstr: ', mstr);
  if ((site == null) || site.length === 0) {
    $("password").value = "";
  }
  $("site").focus();
  hash = genHash(site + mstr);
  if (((ref = stash.configs) != null ? ref[hash] : void 0) != null) {
    return pass = showPassword(stash.configs[hash]);
  } else {
    return newSite(site);
  }
};
