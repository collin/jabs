require 'haml'
require 'fold'
require 'johnson'

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
      parse text
    end

    folds :Selector, /^\$/ do
      call(
        access(jquery([:string, text]), [:name, "each"]), 
        function(nil, [], [:source_elements, render_children])
      )
    end

    def set_this
      [[:var_statement, [[:assign_expr, [:name, "thi$"], jquery([:this])]]]]
    end

    folds :SubSelector, /^&/ do
      call(
        access(
          call(access([:name, "this"], [:name, "find"]), [:string, text]),
          [:name, "each"]
        ),
        function(nil, [], [:source_elements, render_children])
      )
    end

    folds :Event, /^:/ do
      event_bind(text, jquery([:name, "this"]), [:source_elements, render_children])
    end

    folds :Ready, /^:ready/ do
      jquery(function(nil,  [], [:source_elements, render_children]))
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

    def parse expression
      Johnson::Parser.parse(expression).value.first
    end

    def source block=nil
      source = [:source_elements]
      source << [block] unless(block.nil? or block.empty?)
      source
    end

    def event_bind event, binds_to, function_sexp=nil
      call(access(binds_to, [:name, "bind"]), [:string, event], function(nil,  [], function_sexp))
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
# )
#     def klass
#       var = johnsonize [:var_statement]
#       var << johnsonize([:assign_expr, 
#         [:name, @p.klass],
#         [:object_literal, [
# #           [:property, 
# #             [:name, 'templates'],
# #             [:object_literal]
# #           ]
#         ]]
#       ])
#       var
#     end
# 
#     def extend mod, properties
#       johnsonize [:function_call, [ 
#         [:dot_accessor,
#           [:name, 'extend'],
#           [:name, 'jQuery']],
#         [:dot_accessor,
#           [:name, mod],
#           [:name, @p.klass]],
#         [:object_literal,
#           properties
#         ]
#       ]]
#     end
# 
#     def templates
#       @p.templates.map do |key, value|
#         johnsonize [:function_call, [
#           [:dot_accessor,
#             [:name, 'Template'],
#             [:name, 'Lucky7']
#           ],
#           [:string, key],
#           [:string, value]
#         ]]
#       end.first
# #       extend('templates', @p.templates.map{|key,value|
# #          [:property, 
# #           [:name, key],
# #           [:string, value]
# #         ]
# #       })
#     end
# 
#     def jquery_bind bind_to=[], *bind_args
#       [:function_call, [
#         [:dot_accessor,
#           [:name, 'bind'],
#           jquery(*bind_to)
#         ],
#         *bind_args
#       ]]
#     end
# 
# 
#     def actions
#       johnsonize jquery_bind([:name, 'document'],
#         [:string, 'ready'],
#         [:function, nil, [], [:source_elements, [
#           jquery_bind([:string, ".#{@p.klass}"],
#             [:object_literal,
#               @p.actions.map do |action, segments|
#                 [:property, 
#                   [:string, action],
#                   [:function, nil, ['event'], 
#                     [:source_elements,
#                       ([[:var_statement, [
#                         [:assign_expr,
#                           [:name, 'el'],
#                           [:function_call, [
#                             [:name, 'jQuery'],
#                             [:dot_accessor,
#                               [:name, 'target'],
#                               [:name, 'event']
#                             ]
#                           ]]
#                         ]
#                       ]]] +
#                       segments.map do |segment|
#                         [:if,
#                           [:function_call, [
#                             [:dot_accessor, 
#                               [:name, 'is'],
#                               [:name, "el"]
#                             ],
#                             [:string, segment[:selectors].map{|s| @p.selectors[s]}.join(', ')],
#                           ]],
#                           segment[:javascript],
#                           nil
#                         ]
#                       end)
#                     ]
#                   ]
#                 ]
#               end
#             ])
#       ]]])
#     end
  end
end
