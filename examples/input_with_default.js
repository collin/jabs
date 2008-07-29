jQuery(function() {
  (function($this) {
    (function($this) {
      $this.bind("blur", function(e) {
        var $this = jQuery(this);
        if($this.attr("value") === "") {
          $this.attr("value", $this.attr("default_value"));
}
});
      $this.bind("focus", function(e) {
        var $this = jQuery(this);
        if($this.attr("value") === $this.attr("default_value")) {
          $this.attr("value", "");
}
});
      $this.blur();
})(jQuery("input[default_value]"));
})(jQuery(window));
});