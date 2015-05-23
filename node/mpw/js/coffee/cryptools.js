
/*
 0000000  00000000   000   000  00000000   000000000   0000000    0000000   000       0000000
000       000   000   000 000   000   000     000     000   000  000   000  000      000     
000       0000000      00000    00000000      000     000   000  000   000  000      0000000 
000       000   000     000     000           000     000   000  000   000  000           000
 0000000  000   000     000     000           000      0000000    0000000   0000000  0000000
 */
var bcrypt, cipherType, crypto, decrypt, decryptFile, encrypt, encryptFile, exp, fileEncoding, fs, genHash, genSalt, zipObject;

fs = require('fs');

crypto = require('crypto');

bcrypt = require('bcrypt');

zipObject = require('lodash.zipobject');

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

encryptFile = function(file, buffer, key) {
  var encrypted;
  encrypted = encrypt(buffer, key);
  return fs.writeFileSync(file, encrypted, fileEncoding);
};

decryptFile = function(file, key, cb) {
  var encrypted;
  if (fs.existsSync(file)) {
    try {
      encrypted = fs.readFileSync(file, fileEncoding);
    } catch (_error) {
      cb(['can\'t read file at', file]);
      return;
    }
    try {
      return cb(null, decrypt(encrypted, key));
    } catch (_error) {
      return cb(['can\'t decrypt file', file]);
    }
  } else {
    return cb(['no file at', file]);
  }
};

genHash = function(value) {
  return crypto.createHash('sha512').update(value).digest('hex');
};

genSalt = function(length) {
  var salt;
  salt = "";
  while (salt.length < length) {
    salt += bcrypt.genSaltSync(12).substr(10);
  }
  return salt.substr(0, length);
};

exp = ['encrypt', 'decrypt', 'decryptFile', 'encryptFile', 'genHash', 'genSalt'];

module.exports = zipObject(exp.map(function(e) {
  return [e, eval(e)];
}));
