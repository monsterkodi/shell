var _s, re;

_s = require('underscore.string');

re = /(^|\s|(?:http[s]?:\/\/))(?:[\w-]+\.)+\w[\w-]+(?::[1-9]\d+)?(?:\/[\w\.-~]*)*[\?\w\d\+\-\.,;=&\/#%\$]*(?:\s|$)/;

exports.extractSite = function(str) {
  var r, s;
  r = /(^|\s|(?:http[s]?:\/\/))((?:[\w-]+\.)+\w[\w-]+)(?::[1-9]\d+)?(?:\/[\w\.-~]*)*[\?\w\d\+\-\.,;=&\/#%\$]*(?:\s|$)/;
  s = str.match(r)[2];
  if (_s.startsWith(s, 'www.')) {
    s = s.substr(4);
  }
  return s;
};

exports.containsLink = function(str) {
  return str.search(re) >= 0;
};

exports.shortenLink = function(str, len) {
  var host, s;
  len = len || 10;
  if ((s = str.indexOf('://')) > -1) {
    str = str.substr(s + 3);
  }
  if (str.indexOf('www.') === 0) {
    str = str.substr(4);
  }
  if ((s = str.lastIndexOf('?')) > -1) {
    str = str.substr(0, s);
  }
  if ((s = str.lastIndexOf('.htm')) > -1) {
    str = str.substr(0, s);
  }
  if ((s = str.lastIndexOf('/')) === str.length - 1) {
    str = str.substr(0, s);
  }
  if (str.length > len) {
    s = str.split('/');
    host = s.splice(0, 1)[0].split('.');
    str = [host[host.length - 2]].concat(s).join('/');
  }
  if (str.length > len) {
    s = str.split('/');
    if (s.length > 2) {
      str = s[0] + "..." + s[s.length - 1];
    }
  }
  return str;
};
