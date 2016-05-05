(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
(function() {
  var $, getStock, key, log, sh, sw;

  log = function() {
    var str;
    str = ([].slice.call(arguments, 0)).join(" ");
    return console.log(str);
  };

  $ = function(id) {
    return document.getElementById(id);
  };

  sw = function() {
    return $('body').clientWidth;
  };

  sh = function() {
    return $('body').clientHeight - $('chart').clientHeight;
  };

  key = window.location.search.substring(1);

  getStock = function(stock) {
    var api, arg, bg, k, opt, req, s, title, v, yearLines;
    s = Snap();
    s.attr({
      viewBox: '0 0 1000 100',
      overflow: 'visible'
    });
    bg = s.rect();
    bg.attr({
      id: stock,
      "class": 'bg',
      width: 1000,
      height: 97,
      rx: 10,
      ry: 10
    });
    yearLines = function(s, delta, num, offset) {
      var j, mid, ref, results, x, y;
      x = offset;
      results = [];
      for (y = j = 0, ref = num; 0 <= ref ? j < ref : j > ref; y = 0 <= ref ? ++j : --j) {
        mid = s.line();
        mid.attr({
          "class": 'time',
          x1: x,
          y1: 0,
          x2: x,
          y2: 97
        });
        results.push(x += delta);
      }
      return results;
    };
    yearLines(s, 24, 13, 24);
    yearLines(s, 104, 3, 13 * 24 + 104);
    title = s.text();
    title.attr({
      x: 10,
      y: 20,
      "class": 'title',
      text: stock
    });
    req = new XMLHttpRequest();
    req.stock = stock;
    req.s = s;
    req.addEventListener("load", function() {
      var d, data, i, j, l, m, max, ny, ref, results, set, v, values, x, y;
      data = JSON.parse(this.response);
      set = data.dataset;
      values = (function() {
        var j, len, ref, results;
        ref = set.data;
        results = [];
        for (j = 0, len = ref.length; j < len; j++) {
          d = ref[j];
          results.push(d[1]);
        }
        return results;
      })();
      max = Math.max.apply(null, values);
      y = parseInt(set.data[0][0].substr(2, 2));
      m = parseInt(set.data[0][0].substr(5, 2));
      x = (y * 12 + m) * 2;
      y = 97 - 97 * values[0] / max;
      results = [];
      for (i = j = 1, ref = values.length; 1 <= ref ? j < ref : j > ref; i = 1 <= ref ? ++j : --j) {
        v = values[i];
        l = this.s.line();
        x += 2;
        ny = 97 - 97 * v / max;
        l.attr({
          "class": 'long',
          x1: x - 2,
          y1: y,
          x2: x,
          y2: ny
        });
        results.push(y = ny);
      }
      return results;
    });
    arg = {
      start_date: "2000-01-01",
      end_date: "2017-01-01",
      collapse: "monthly",
      column_index: 11,
      order: 'asc'
    };
    opt = ((function() {
      var results;
      results = [];
      for (k in arg) {
        v = arg[k];
        results.push(k + "=" + v);
      }
      return results;
    })()).join("&");
    api = "https://www.quandl.com/api/v3/datasets/WIKI/";
    req.open('GET', "" + api + stock + ".json?" + opt + "&api_key=" + key, true);
    req.send();
    req = new XMLHttpRequest();
    req.stock = stock;
    req.s = s;
    req.addEventListener("load", function() {
      var d, data, i, j, l, max, ny, ref, set, values, x, y;
      data = JSON.parse(this.response);
      set = data.dataset;
      values = (function() {
        var j, len, ref, results;
        ref = set.data;
        results = [];
        for (j = 0, len = ref.length; j < len; j++) {
          d = ref[j];
          results.push(d[1]);
        }
        return results;
      })();
      max = Math.max.apply(null, values);
      x = 13 * 24;
      y = 97 - 97 * values[0] / max;
      for (i = j = 1, ref = values.length; 1 <= ref ? j < ref : j > ref; i = 1 <= ref ? ++j : --j) {
        v = values[i];
        l = this.s.line();
        x += 2;
        ny = 97 - 97 * v / max;
        l.attr({
          "class": 'mid',
          x1: x - 2,
          y1: y,
          x2: x,
          y2: ny
        });
        y = ny;
      }
      req = new XMLHttpRequest();
      req.stock = this.stock;
      req.s = this.s;
      req.max = max;
      req.addEventListener("load", function() {
        var n, ref1, results;
        data = JSON.parse(this.response);
        set = data.dataset;
        values = (function() {
          var len, n, ref1, results;
          ref1 = set.data;
          results = [];
          for (n = 0, len = ref1.length; n < len; n++) {
            d = ref1[n];
            results.push(d[1]);
          }
          return results;
        })();
        x = 13 * 24 + 104 * 3;
        y = 97 - 97 * values[0] / max;
        results = [];
        for (i = n = 1, ref1 = values.length; 1 <= ref1 ? n < ref1 : n > ref1; i = 1 <= ref1 ? ++n : --n) {
          v = values[i];
          l = this.s.line();
          x += 2;
          ny = 97 - 97 * v / max;
          l.attr({
            "class": 'short',
            x1: x - 2,
            y1: y,
            x2: x,
            y2: ny
          });
          results.push(y = ny);
        }
        return results;
      });
      arg = {
        start_date: "2016-01-01",
        end_date: "2017-01-01",
        collapse: "dayly",
        column_index: 11,
        order: 'asc'
      };
      opt = ((function() {
        var results;
        results = [];
        for (k in arg) {
          v = arg[k];
          results.push(k + "=" + v);
        }
        return results;
      })()).join("&");
      api = "https://www.quandl.com/api/v3/datasets/WIKI/";
      req.open('GET', "" + api + stock + ".json?" + opt + "&api_key=" + key, true);
      return req.send();
    });
    arg = {
      start_date: "2013-01-01",
      end_date: "2017-01-01",
      collapse: "weekly",
      column_index: 11,
      order: 'asc'
    };
    opt = ((function() {
      var results;
      results = [];
      for (k in arg) {
        v = arg[k];
        results.push(k + "=" + v);
      }
      return results;
    })()).join("&");
    api = "https://www.quandl.com/api/v3/datasets/WIKI/";
    req.open('GET', "" + api + stock + ".json?" + opt + "&api_key=" + key, true);
    return req.send();
  };

  window.onload = function() {
    getStock("AAPL");
    getStock("TSLA");
    getStock("SCTY");
    getStock("FB");
    getStock("GOOGL");
    getStock("AMZN");
    getStock("MSFT");
    getStock("BA");
    getStock("LMT");
    return getStock("NOC");
  };

}).call(this);

},{}]},{},[1]);
