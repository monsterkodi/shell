var _url, clearSeed, clipboard, containsLink, cryptools, decrypt, decryptFile, default_pattern, dirty, encrypt, error, extractSite, fs, genHash, jsonStr, main, makePassword, masterBlurred, masterChanged, masterFocus, mstr, newSeed, newSite, numConfigs, pad, password, passwordBlurred, passwordFocus, readStash, setSite, showPassword, siteBlurred, siteChanged, siteFocus, stash, stashFile, trim, undirty, updateSitePassword, win, writeStash;

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

stashFile = process.env.HOME + '/.config/pwm.stash';

stash = {};

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
  var clip;
  $("master").on('focus', masterFocus);
  $("master").on('blur', masterBlurred);
  $("site").on('focus', siteFocus);
  $("site").on('blur', siteBlurred);
  $("password").on('focus', passwordFocus);
  $("password").on('blur', passwordBlurred);
  $("master").on('input', masterChanged);
  $("site").on('input', siteChanged);
  $("master").focus();
  clip = clipboard.readText();
  if (containsLink(clip)) {
    return setSite(extractSite(clip));
  }
});

win.on('focus', function(event) {
  if ((mstr != null) && mstr.length) {
    $("site").focus();
    return $("site").setSelectionRange(0, $("site").value.length);
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
  console.log(pass);
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
    return pass = showPassword(stash.configs[hash]);
  } else {
    return newSite(site);
  }
};
