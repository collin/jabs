module Jabs
  class Engine < Fold::Engine
    def render context=nil
      @p = precompiler_class.new
      root = Johnson::Nodes::SourceElements.new 0, 0
      main = Johnson::Nodes::SourceElements.new 0, 0
      root << @p.johnsonize(@p.call([:function, nil, [], main]))
      
      @p.fold(lines).children.each{|c|main << @p.johnsonize(c.render)}
      root.to_ecma
    rescue Fold::FoldFactory::IndentationError => e
      require 'pp'
      pp lines
      puts "______------UP"
      raise e
    end
  end
end