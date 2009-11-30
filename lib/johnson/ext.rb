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
      def visit_SourceElements(o)
        newline = o.value.length > 0 ? "\n" : ' '
        (@depth == 0 ? '' : "{#{newline}") +
          indent {
            o.value.map { |x|
              code = x.accept(self)
              semi = case x
                     when Nodes::FallThrough
                      ""
                     when Nodes::Function, Nodes::While, Nodes::If, Nodes::Try, Nodes::Switch, Nodes::Case, Nodes::Default, Nodes::For, Nodes::ForIn
                       code =~ /\}\Z/ ? '' : ';'
                     else
                       ';'
                     end
              "#{indent}#{code}#{semi}"
            }.join("\n")
          } +
          (@depth == 0 ? '' : "#{newline}}")
      end

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
