module Jabs
  class Precompiler < Fold::Precompiler
    class << self
      attr_accessor :spot_replacements
    end

    self.spot_replacements = []

    def self.spot_replace key, &block
      spot_replacements << block if block_given?
    end

    attr_reader :sexp, :current_sexp

    def initialize
      super
      
      @ready = false
      @current_sexp = []
      @full_sexp = [:source_elements, @current_sexp]
    end

    folds :Line, // do
      if children.reject{|child| child.is_a?(Line) }.any?
        call(function(nil, ["$this"], [:source_elements, render_children]), jquery(Johnson::Parser.parse(text).value.first))
      else
        [:fall_through, (Precompiler.do_spot_replace(text, self) + children.map{|child| child.text}.join(""))]
      end
    end

    folds :Selector, /^\$/ do
      call(function(nil, ["$this"], [:source_elements, render_children]), jquery([:string, text]))
    end

    folds :SubSelector, /^&/ do
      call(
        function(nil, ["$this"], [:source_elements, render_children]),
        call(access([:name, "$this"], [:name, "find"]), [:string, text])
      )
    end

    folds :Event, /^:/ do
      event_bind(text, [:name, "$this"], [:source_elements, [parse("var $this = jQuery(this)")] + render_children])
    end

    folds :Ready, /^:ready/ do
      jquery(function(nil,  [], [:source_elements, [call(function(nil, ["$this"], [:source_elements, render_children]), jquery([:name, "window"]))]]))
    end

    folds :Function, /^fun / do
      parts = text.split(/ /)
      name, arg_names = parts.shift, parts.join('').gsub(' ', '').split(',')
      [:function, name, arg_names, [:source_elements, render_children]]
    end

    folds :Def, /^def / do
      parts = text.split(/ /)
      name, arg_names = parts.shift, parts.join('').gsub(' ', '').split(',')
      [:assign_expr, 
        access(access([:name, "jQuery"], [:name, "fn"]), [:name, name]),
        [:function, nil, arg_names, [:source_elements, [parse("var $this = this")] + render_children]]]
    end

    if_meta = %q{
      index = parent.children.index(self)
      _next =  parent.children.slice index + 1
      
      _else = if [Else, ElseIf].include? _next.class
        _next.render
      else
        nil
      end
      [:if, parse(Precompiler.do_spot_replace(text)),[:source_elements, render_children], _else]
    }

    folds :If, /^if / do
      eval if_meta
    end

    folds :Unless, /^unless / do
      [:if, [:not, [:parenthesis, parse(Precompiler.do_spot_replace(text))]], [:source_elements, render_children], nil]
    end

    folds :Else, /^else/ do
      [:source_elements, render_children]
    end

    folds :ElseIf, /^else if/ do
      eval if_meta
    end

    folds :DotAccessor, /^\./ do
      if children.find_all{|child| child.text[/^[\w\d]*?:/]}.any? and not(text[/\{/])
        break if text[/\{|\}/]
        self.text << "(" << johnsonize([:object_literal, children.map do |child| 
          key, value = *child.text.split(":")
          [:property, [:string, key], parse(value)]
        end]).to_ecma.gsub(",\n", ",") << ")"
        self.children = []
      end

      index = parent.children.index(self)
      _next =  parent.children.slice index + 1
      _text = _next ? _next.text : ""

      if children.any?
        if (_text[/\}\)/])
          [:fall_through, ("$this."+Precompiler.do_spot_replace(text, self) + children.map{|child| child.text}.join(""))]
        else
          call(
            function(nil, ["$this"], [:source_elements, render_children]),
            parse(Precompiler.do_spot_replace(".#{text}", self))
          )
        end
      else
        parse Precompiler.do_spot_replace(".#{text}", self)
      end
    end

    spot_replace :DotAccessor do |expression, precompiler|
      expression.gsub /(^\.([\w]+)|- \.(.+))(.*)/ do |match|
        "$this#{Precompiler.compile_arguments expression, $1, match, $4}"
      end
    end

    spot_replace :AccessUpAndCall do |expression, precompiler|
      expression.gsub /\.\.(\..*)/ do |match|
        "$this.prevObject#{Precompiler.do_spot_replace($1)}"
      end
    end

    spot_replace :AccessUpUp do |expression, precompiler|
      expression.
        gsub(/ \.\.\/|^\.\.\//, "$this.prevObject/").
        gsub(/\/\.\./, ".prevObject")
    end    
    
    spot_replace :AccessUp do |expression, precompiler|
      expression.gsub /\.\./ do
        "$this.prevObject"
      end
    end

    spot_replace :AttributeSetter do |expression, precompiler|
      expression.gsub /@([\w]+)[ ]*=[ ]*(.*)/ do |match|
        if $2[0] == ?=
          match
        else
          "$this.attr('#{$1}', #{Precompiler.do_spot_replace $2, precompiler})"
        end
      end
    end
    
    spot_replace :AttributeAccessor do |expression, precompiler|
      expression.gsub /@([\w]+)/ do
        "$this.attr('#{$1}')"
      end
    end

    spot_replace :DanglingThis do |expression, precompiler|
      expression.gsub /prevObject\$this/ do
        "prevObject"
      end
    end

    def self.do_spot_replace expression, precompiler=nil
      spot_replacements.each do |block|
        expression = block.call(expression, precompiler)
      end
      expression
    end

    def self.compile_arguments expression, call, real, args
      return real if expression[Regexp.new("^\\#{call}\\(")]
      arguments = []
      if args[/^\./]
        "#{call}()#{do_spot_replace(args).gsub("$this", "")}"
      else
        args.split(/\s|,/).each do |arg|
          arg.gsub!(/:(\w+)/) {%{"#{$1}"}}
          next if arg[/\s/]
          next if arg == ""
          arguments << arg
        end
        "#{call}(#{arguments.join(', ')})"
      end
    end

    def parse expression
      self.class.do_spot_replace expression, self
      Johnson::Parser.parse(expression).value.first
    end

    def source block=nil
      source = [:source_elements]
      source << [block] unless(block.nil? or block.empty?)
      source
    end

    def event_bind event, binds_to, function_sexp=nil
      call(access(binds_to, [:name, "live"]), [:string, event], function(nil,  ["event"], function_sexp))
    end

    def call *args
      [:function_call, args]
    end

    def onready function_sexp=nil
      event_bind('ready', jquery([:name, "document"]), function_sexp)
    end

    def access left, right
      [:dot_accessor, right, left]
    end

    def function name=nil, args=[], function_sexp=nil
      [:function, name, args, function_sexp]
    end

    def jquery *jquery_arg
      [:function_call, [
        [:name, 'jQuery'],
        *jquery_arg
      ]]
    end

    def johnsonize(sexp)
      return sexp if sexp.is_a?(Johnson::Nodes::Node)
      return sexp if sexp.class.to_s == "String"
      return [] if sexp === []
      return nil if sexp === nil
      unless sexp.first.class.to_s == "Array"
        if sexp.first.class.to_s == "Symbol"
          klass = eval("Johnson::Nodes::#{sexp.shift.to_s.camelcase}")
          klass.new 0,0, *sexp.map{|n|johnsonize(n)}
        elsif sexp.is_a? Array
          sexp.map{|n|johnsonize(n)}
        else
          sexp
        end
      else
        sexp.map{|n|johnsonize(n)}
      end
    end  
  end
  
end