module Jabs
  class Engine < Fold::Engine
    def render context=nil
      @p = precompiler_class.new
      root = Johnson::Nodes::SourceElements.new 0, 0
      @p.fold(lines).children.each{|c|root << @p.johnsonize(c.render)}
      root.to_ecma
    end
  end
end