var Backspace = 8;
var Tab = 9;
var Enter = 13;
var Shift = 16;
var Ctrl = 17;
var Alt = 18;
var PauseBreak = 19;
var CapsLock = 20;
var Escape = 27;
var PageUp = 33;
var PageDown = 34;
var PageEnd = 35;
var PageHome = 36;
var Left = 37;
var Up = 38;
var Right = 39;
var Down = 40;
var Insert = 45;
var Delete = 46;
jQuery.fn.blink = function() {
  this.toggle();
  var that = this;
  t = window.setTimeout(function() {
    that.blink();
}, 1000);
  return this;
};
jQuery(function() {
  (function($this) {
    $this.bind("keypress", function(e) {
      e.preventDefault();
      (function($this) {
        $this.show();
        function insert(val) {
          $this.before(val);
}
        if(e.charCode) {
          insert("<span>" + String.fromCharCode(e.charCode) + "</span>");
}
        if(e.keyCode === Backspace) {
          $this.prev().remove();
}
        if(e.keyCode === Left) {
          $this.prev().before($this);
}
        if(e.keyCode === Right) {
          $this.next().after($this);
}
        if(e.keyCode === Enter) {
          insert("<br/>");
}
})(jQuery("#cursor"));
});
    (function($this) {
      $this.blink();
})(jQuery("#cursor"));
})(jQuery(window));
});