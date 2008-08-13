require 'rubygems'
require 'haml'
require 'fold'
require 'johnson'

module Johnson
  module Nodes
    attr_accessor :value
    class FallThrough < Node
      def initialize(_row, _column, value)
        @value = value
      end
    end
  end

  module Visitors
    class EcmaVisitor
      def visit_FallThrough(o)
        o.value
      end
    end

    class SexpVisitor
      def visit_FallThrough(o)
        [:fall_through, o.value]
      end
    end
  end
end

module Jabs
  include Johnson::Nodes
  
  class Precompiler < Fold::Precompiler
    attr_reader :sexp, :current_sexp

    def initialize
      super
      
      @waiting_else = []
      @ready = false
      @current_sexp = []
      @full_sexp = [:source_elements, @current_sexp]
    end

    folds :Line, // do
      [:fall_through, (spot_replace(text) + children.map{|child| child.text}.join(""))]
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

    folds :If, /^if / do
      _if = johnsonize [:if, parse(text),[:source_elements, render_children], nil]
      @waiting_else = _if
      _if
    end

    folds :Unless, /^unless / do
      _unless = johnsonize [:if, [:not, [:parenthesis, parse(text)]], [:source_elements, render_children], nil]
      @waiting_else = _unless
      _unless
    end

    folds :Else, /^else/ do
      @waiting_else.shift
      @waiting_else << [:source_elements, render_children]
      ""
    end

    def spot_replace expression

# Implied .dot.accessors

  # Floating free

      expression.gsub! /- \.([\w]+)/ do; " $this.#{$1}" end

  # Or the beginning of a line

      expression.gsub! /^\.([\w]+)/ do; "$this.#{$1}" end

# @ttribute setters

      expression.gsub! /@([\w]+)[ ]*=[ ]*(.*)/ do |match|
  # Catch comparisons
        if $2[0] == ?=
          match
        else
          "$this.attr('#{$1}', #{spot_replace $2})"
        end
      end

# @ttribute accessors

      expression.gsub! /@([\w]+)/ do; "$this.attr('#{$1}')" end

      expression
    end

    def parse expression
      expression = spot_replace expression
      Johnson::Parser.parse(expression).value.first
    end

    def source block=nil
      source = [:source_elements]
      source << [block] unless(block.nil? or block.empty?)
      source
    end

    def event_bind event, binds_to, function_sexp=nil
      call(access(binds_to, [:name, "bind"]), [:string, event], function(nil,  ["e"], function_sexp))
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
  
  class Engine < Fold::Engine

    def render context=nil
      @p = precompiler_class.new
      root = Johnson::Nodes::SourceElements.new 0, 0
      @p.fold(lines).children.each{|c|root << @p.johnsonize(c.render)}
      root.to_ecma
    end
  end
end

puts Jabs::Engine.new($stdin.read).render if $0 == __FILE__
