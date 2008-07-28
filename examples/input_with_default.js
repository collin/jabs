jQuery(function() {
  (function($this) {
    $this.bind("blur", function() {
      if($this.attr("value") === "") {
        $this.attr("value", $this.attr("default_value"));
}
});
    $this.bind("focus", function() {
      if($this.attr("value") === $this.attr("default_value")) {
        $this.attr("value", "");
}
});
    $this.blur();
})(jQuery("input[default_value]"));
});