Javascript Abstract Behavior Syntax? What's that?

Last yeer I was working on a project *very* similar to http://github.com/nex3/jabl in the months running up to RubyFringe.

Then I saw Hampton's presenation. Oops.

But now over a year has passed and there is no Jabl/Jabs or whatever one would decide to call it. (http://ejohn.org/apps/jquery2/)

So screw it. Now is the time for Jabs.

  jQuery(function() {
    var $ = jQuery;
  
    $("[data-default_value]")
      .blur(function() {
        var self = $(this);
        if(self.val() === "") {
          self.val(self.attr("data-default_value"));
        }
      })
      .focus(function() {
        var self = $(this);
        if(self.val === self.attr("data-default_value")) {
          self.val("");
        }
      })
      .blur(); 
  });

Would you rather code that
--------------------------

Or this?
========

  $ [data-default_value]
    :blur
      if @value === ""
        @value = @data-default_value
    :focus
      if @value === @data-default_value
        @value = ""
    .blur

Javascript
==========
Jabs is a

Selectors
=========