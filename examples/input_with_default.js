jQuery(function() {
  jQuery("input[default_value]").each(function() {
    var value = jQuery(this).attr("default_value");
    jQuery(this).bind("blur", function() {
      console.log(jQuery(this).val() === "");
      if(jQuery(this).val() === "") {
        jQuery(this).val(value);
}
});
    jQuery(this).bind("focus", function() {
      if(jQuery(this).val() === value) {
        jQuery(this).val("");
}
});
    jQuery(this).blur();
});
});