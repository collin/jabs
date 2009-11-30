Javascript Abstract Behavior Syntax? What's that?

Last yeer I was working on a project *very* similar to http://github.com/nex3/jabl in the months running up to RubyFringe.

Then I saw Hampton's presenation. Oops.

But now over a year has passed and there is no Jabl/Jabs or whatever one would decide to call it. (http://ejohn.org/apps/jquery2/)

So screw it. Now is the time for Jabs.

Would you rather code this?

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

Or this?

    $ [data-default_value]
      :blur
        if @value === ""
          @value = @default_value
      :focus
        if @value === @default_value
          @value = ""
      .blur

Video
=====
[Watch the quick code-demo video.](http://www.youtube.com/watch?v=JdnXJ6bj_qs)

Install
=======

Let's kick things off and look at all of Jabs' fun-filled features.

gem install jabs

JavaScript
==========

It can be scary to leave the world of JavaScript for the madness that is Jabs. But fear not.
For Jabs treats JavaScript like the good friend it is. When Jabs encounters a line it doesn't understand
it treats it as JavaScript and doesn't make any modifications. This lets us do things like this

    $#selector
      MySpecialObject.method($this, {
        option_one: "value"
      });

It even let's the real javascript spill over into other lines. Do be careful, the law of whitespace still
applies here. Two spaces per level of indentation.

Selectors
=========

Jabs pays special attention to lines that begin with a dollar sign. These are the selectors.

    $ .plan > img
    // Is analogous to
    $(".plan > img")

When you've figured out your selector, enter a new line and indent. Two spaces. Always.
At the root of a Jabs program, the context is $(window).

Jabs borrows an idea from Sass and lets you go deeper into a selector.

    $ .plan
      &img
    // Is analogous to
    $('.plan').find('img')
  

Implied Self & Automatic Method Calling
=======================================

In normal Javascript whenever you want to do something in the current context you have to go fishing for the 'this' object.

    this.doSomething()

But in Jabs there is an implied self.

    .doSomething

Jabs comes with something else, methods will automatically be called just by being referenced. Parenthesis are not required.
Arguments may also by supplied with or without parenthesis.

    $#element
      .fadeOut 'slow'

Hash Literal Syntax
===================
Some methods, like .css take a hash. To make life easier with these methods a lean hash literal has been provided.

    $#element
        .css
            background: #fcc
            z-index: 2000

Events
======

Jabs pays attention to lines beginning with ':'. These lines specify event handlers. Jabs has one special event, ':ready'.
This is like the jQuery onReady shortcut.

    :ready
      $body
        .hide
    // Is analogous to
    jQuery(function(event) {
      $('body').hide()
    })

Events are bound with the jQuery live method. Where necessary, plugins have been provided to ensure all
events work with the event delegation of live.

    // access to the event object is also provided
    $#element
    :click
      .text(event.charCode)

Attributes
==========

Who wants to go around looking up attributes on DOM nodes like this?

    $(this).attr('some_attr', "some value")

Nobody at Jabs HQ. We borrow a syntactic sensibility from Ruby and access our attributes with the at sign.
This works for both getting and setting attributes.

    &lt;input default_value="Search..." /&gt;
    // with Jabs we can write:
    $input
      @value = @default_value
    // Or with jQuery
    $('input').val($('input').attr('default_value'))

The attribute syntax also works in the middle of lines and always gets and sets attributes on the DOM node of the
current context.

Path Accessors
==============

jQuery has a little used property, "prevObject". It allows you to do this:

    el = $('#element')
    el.find('img')
    el.prevObject.is('#element') == true // true

Jabs provides a lean way to access various levels of the jQuery object in-line.

    $#element
      &li
        // Works with implied self
        ...is('#element') == true
        // Works with attributes
        ..@id = @parent_id + "_element"
        // And travels up more than one step
        &img
          @parent_id = ../..@id
  

Automatic jQuery Wrapper
========================

Jabs provides an automatic jQuery wrapper where it makes sense.
Take the example of an event handler.

    $#element
      :click
        event.target
          .fadeOut 'slow'
    // Is analogous to
    $('#element').click(function(event) {
      $(event.target).fadeOut('slow');
    });

Conditionals
============

Jabs introduces Ruby style conditionals. They are a joy to use.

    if 3 === 4
      unless 4 === 3
        if 3 === 3

    var a = cat
    if 3 === 4
      var elk = "3"
      unless 4 === 3
        wear.your.pants()
        if 3 === 3

    if 1 == 2
      "yay"
    else if 3 == 4
      "poo"
    else
      "huh"

These are all valid conditionals. You may use @ttributes and path accessors in conditionals.

Functions
=========

Jabs lets you define functions. Functions are scoped by the level of indentation.

    fun my_function foo, bar
      console.log(foo, bar)
  
Remember, if you run into a syntax you can't quite lick, Jabs always lets you write plain old
Javascript right in the middle of a Jabs file.

Methods
=======

Jabs wants you to define methods for DOM node contexts.

    // This method only allows certain characters to be typed into an input
    def whitelist regex
      :keypress
        if event.charCode > 0 && !String.fromCharCode(e.which).match(expr))
          event.preventDefault()

    $input.digits
      .whitelist /[\d]/

Nice. It's pretty simple.

Drag & Drop
===========

Jabs ships with a library for simple drag and drop programming.
Here's a simple example of it in action.

    def sortable parent_selector
      :dragstart
        event.target
          .closest parent_selector
            .clone
              .css
                position: 'absolute'
              .appendTo document.body

      :drag
        event.dragProxy
          .css
            top: event.pageY
            left: event.pageX

      :dragend
        event.dragProxy 
          .remove

Learn more about the drag and drop libraries being used: http://blog.threedubmedia.com/2008/08/eventspecialdrag.html

Rack Middleware
===============

Jabs comes with some special Rack middleware.

    # First a subclass of Rack::Static
    use Jabs::Rack::Static, :urls => '/jabs', :root => 'public/jabs'

    # And secondly a special app that serves the curated
    # <script src="/jquery.js"></script> would do the trick for this rackup file.
    Jabs::Rack.mount(self, '/jquery')

Look at examples/ to see these in action.

License unspecified. Probably MIT or BSD. Don't be a dick.