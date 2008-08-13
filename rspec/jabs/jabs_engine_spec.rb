require 'rspec/jabs_spec_helper'
# $LOAD_PATH << "~/code/johnson/js" unless $LOAD_PATH.include?("~/code/johnson/js")

describe Jabs::Engine do
  def assert_jabs src, target
    src = Johnson::Parser.parse(Jabs::Engine.new(src).render).to_ecma
    target = Johnson::Parser.parse(target).to_ecma
    src.should include(target)
  end

  describe "line" do
    it "passes through" do
      assert_jabs "use.real[\"javascript\"] == true;", "use.real[\"javascript\"] == true;"
    end

    it "renders multiple lines" do
      assert_jabs "one;\ntwo;", "one;\ntwo;"
    end

    it "doesn't throw up when given nested lines" do
      assert_jabs %{var coolio = { val: \"to the store\"};}, %{ 
var coolio = {
  val: "to the store"
};
}
    end

    it "understands function literals across lines" do
      assert_jabs %{
function() {
  doCall.apply(null);
}
}, %{function() {doCall.apply(null);}}
    end
  end

  describe "functions" do
    it "compiles funs with arbirtrary javascript" do
      assert_jabs %{
fun one
  var a = b
  fun two
}, %{
function one() {
  var a = b;
  function two() {}
}
}

    end
    it "compiles funs into functions" do
      assert_jabs "fun do_something", "function do_something() {}"
    end

    it "compiles with argument lists" do
      assert_jabs "fun do_something has, arguments", "function do_something(has, arguments) {}"
    end

    it "compiles on multiple lines" do
      assert_jabs "fun one\nfun two", "function one() {}; function two() {};"
    end
    

    it "compiles nesting funs" do
      assert_jabs %{
fun outer
  fun inner
  fun inner_two
},%{
function outer() {
  function inner() {
  }
  function inner_two() {
  }
}  
}
    end

    it "compiles REAL javascript" do
      assert_jabs %{
fun real
  whatever.you['want'] = "Goes here"
  !stop == true
},%{
function real() {
  whatever.you['want'] = "Goes here";
  !stop == true;
}  
}
    end

    it "compiles empty functions across lines" do
      assert_jabs %{function(){\r\n}}, %{function(){}}
    end
  end

  describe "def" do
    it "adds functions to JQuery.fn" do
      assert_jabs "def whatever", "jQuery.fn.whatever = function() {var $this = this;}"
    end

    it "adds functions with arguments to jQuery.fn" do
      assert_jabs "def whatever you, want", "jQuery.fn.whatever = function(you, want) {var $this = this;}"
    end

    it "compiles jabs normally within def" do
      assert_jabs %{
def sets_default_value
  &[default_value]
}, %{
jQuery.fn.sets_default_value = function() {
  var $this = this;
  (function($this) {})($this.find('[default_value]'))
}
}
    end
  end

  describe "selectors" do
    before(:each) do
      @css = "#very .complex, style.selector[value=\"pants\"]"
    end

    it "makes a query" do
      assert_jabs "$#{@css}", "(function($this) {})(jQuery('#{@css}'));"
    end

    it "renders iterator" do
      assert_jabs "$#{@css}\n  this.rules();", "(function($this) {this.rules();})(jQuery('#{@css}'));"
    end

#     it "wraps with document.ready if not already wrapped" do
#       assert_jabs "$#{@css}", "jQuery(document).bind(\"ready\", function() {jQuery(\"#{@css}\").each(function() {});});"
#     end
  end

  describe "events" do
    it "has a special :ready event" do
      assert_jabs(":ready", "jQuery(function() {\n  (function($this) {  })(jQuery(window));\n});")
    end

    it "has it's own $this" do
      assert_jabs ":click", "var $this = jQuery(this);"
    end

    it "binds events to 'this' and preserves namespace" do
      assert_jabs ":click.awesomely", "$this.bind(\"click.awesomely\", function(e){var $this = jQuery(this);});"
    end

    it "renders callback" do
      assert_jabs ":click.awesomely\n  a()\n  b()", "$this.bind(\"click.awesomely\", function(e){var $this = jQuery(this);a();b();});"
    end

    it "compiles nested with anything with arbitraty javascript inbetween" do
      assert_jabs %{
fun test
  var cat = yum
  :click
},%{ 
function test() {
  var cat = yum;
  $this.bind( 'click', function(e) {var $this = jQuery(this);});
}
}
    end

    it "compiles nested in selector with arbirtary javascript in between" do
      assert_jabs %{
$document
  cars++
  :click
    var cool = "beans"
},%{
(function($this) {
  cars++;
  $this.bind('click', function(e) {
    var $this = jQuery(this);
    var cool = "beans"
  });
})(jQuery("document"));
}
    end

    it "compiles among arbirtary javascript" do
      assert_jabs %{
var cat = poo
:click
  slot++
}, %{
var cat = poo;
$this.bind('click', function(e) {
  var $this = jQuery(this);
  slot++;
});
}
    end
  end

  describe "sub selections" do
    before(:each) {@css= "#some.convoluted:selector"}
    it "queries against this" do
      assert_jabs "&#{@css}", "(function($this) {})($this.find(\"#{@css}\"));"
    end

    it "renders iterator" do
      assert_jabs "&#{@css}\n  a()\n  b()", "(function($this) {a();b();})($this.find(\"#{@css}\"));"
    end
  end

  describe "conditionals" do
    it "compiles if statements" do
      assert_jabs "if 3 == 4", "if(3 == 4) {}"
    end

    it "compiles unless statements" do
      assert_jabs "unless 3 == 4", "if(!(3 == 4)) {}"
    end
  
    it "compiles nesting conditionals" do
      assert_jabs %{
if 3 === 4
  unless 4 === 3
    if 3 === 3
}, %{
if(3 === 4) {
  if(!(4 === 3)) {
    if(3 === 3) {
    }
  }
}
}
    end
  
    it "compiles nesting conditionals with arbitrary code" do
      assert_jabs %{
var a = cat
if 3 === 4
  var elk = "3"
  unless 4 === 3
    wear.your.pants()
    if 3 === 3
}, %{
var a = cat;
if(3 === 4) {
  var elk = "3";
  if(!(4 === 3)) {
    wear.your.pants();
    if(3 === 3) {
    }
  }
}
}
    end

#     it "compiles else branches" do
#       assert_jabs %{
# if 3 == 4
#   onething;
# else
#   something;
# }, %{
# if(3 == 4) {onething;}
# else {something;}
# }
#     end
# 
#     it "compiles else if branches" do
#       assert_jabs "else if 3 == 4", "else if(3 == 4) {}"
#     end
# 
#     it "compiles else unless branches" do
#       assert_jabs "else unless 3 == 4", "else if(!(3 == 4)) {}"
#     end
  end

  describe "../.. access" do
    it "access prevObject" do
      assert_jabs "..", "echo($this.prevObject)"
    end

    it "accesses multiple previous objects" do
      assert_jabs "../..", "$this.prevObject.prevObject"
    end

    it "provides access to attributes of previous objects" do 
      assert_jabs "..@value", "$this.prevObject.attr('value')"
    end

    it "sets attributes of previous objects" do
      assert_jabs "../..@value = 'neat'", "$this.prevObject.prevObject.attr('value', 'neat')"
    end

    it "works inline with current object access and attribute setting" do
      assert_jabs "..@value = @value", "$this.prevObject.attr('value', $this.attr('value'))"
    end

    it "works inline with current object access and attribute setting reveres" do
      assert_jabs "@value = ..@value", "$this.attr('value', $this.prevObject.attr('value'))"
    end

    it "allows method calls" do
      assert_jabs "..hide()", "$this.prevObject.hide()"
    end

    it "works within conditionals" do
      assert_jabs "if ..is('.awesome')", "if($this.prevObject.is('.awesome')) {}"
    end
  end

  describe "dot.access" do
    it "cheats to $this.whatever" do
      assert_jabs ".width()", "$this.width()"
    end
  end

  describe "@ttribute access" do
    it "gets attributes from DOM" do
      assert_jabs "@value", "$this.attr('value')"
    end

    it "happens anywhere on the line" do
      assert_jabs "@value && @other", "$this.attr('value') && $this.attr('other')"
    end

    it "allows for comparison" do
      assert_jabs "@value == @other", "$this.attr('value') == $this.attr('other')"
    end

    it "allows for strict comparison" do
      assert_jabs "@value === @other", "$this.attr('value') === $this.attr('other')"
    end
  end

  describe "@attribute setting" do
    it "sets attributes" do
      assert_jabs "@value = 4", "$this.attr('value', 4)"
    end

    it "sets attributes to other attributes" do
      assert_jabs "@value = @other", "$this.attr('value', $this.attr('other'))"
    end
  end

#   it "compiles jabs to js" do
#     assert_jabs %{
# :ready
#   $input[default_value]
#     var _default = this.attr('default_value')
#     :blur
#       if this.val() === ''
#         this.val(_default)
# 
#     :focus
#       if this.val() === _default
#         this.val('')
# 
#     this.blur()      
# },%{
# jQuery(function() {
#   (function() {
#     var _default = this.attr('default_value');
#     this.bind("blur", function() {
#       if(this.val() === '') {
#         this.val(_default);
#       }
#     });
#     this.bind("focus", function() {
#       if(this.val() === _default) {
#         this.val('');
#       }
#     });
#     this.blur();
#   })(jQuery("input[default_value]"));
# });
# }
#   end
end
