var check_feed = function() {
  $('#feed').load("/live/last_item");
  setTimeout(check_feed, 60000);
}

$(function() {
  $('input[@default_value]').each(function() {
    // clear default value when user clicks
    $(this)
      .focus(function () {
        if (this.value == this.getAttribute('default_value')) {
          $(this)
            .removeClass("grey")
            .attr({'value': ''});
        }
      })
      .blur(function() {
        if(this.value == '') {
          $(this)
            .addClass("grey")
            .attr({'value': this.getAttribute('default_value')})
        }
      })
      .blur()
  });

  // blank out all elements
  // submitted without the user modifying the element
  $('form').submit(function() { $('input[@default_value]').focus(); });

  $('#comments').autolineheight({minWidth:100,ratio:.03});
  
  // No live feed for the moment
  // check_feed();
});

