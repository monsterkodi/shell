var win;

win = (require('remote')).getCurrentWindow();

document.observe('dom:loaded', function() {
  console.log("dom:loaded" + "fark" + $("master"));
  return $("master").focus();
});

win.on('focus', function(event) {
  return $("master").focus();
});

document.on('keydown', function(event) {
  console.log('key ' + event.which);
  if (event.which === 27) {
    win.hide();
  }
  if (event.which === 13) {
    $("site").value = 'hello:' + $("master").value;
    return console.log('check master', $("master").text, $("master").value);
  }
});
