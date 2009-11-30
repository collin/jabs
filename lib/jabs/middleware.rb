module Jabs
  
  module Rack 
    class Static < ::Rack::Static
      def initialize(app, options={})
        super(app, options)
        root = options[:root] || Dir.pwd
        @file_server = Jabs::Rack::File.new(root)
      end
    end
    
    class File < ::Rack::File
      def serving
        @path += ".jabs" unless @path[/\.jabs$/]
        status, headers, body = * super
        return [status, headers, body] unless status == 200
        
        jabs = Jabs::Engine.new(open(body.path).read).render
        
        headers['Content-Type'] = 'text/javascript'
        headers['Content-Length'] = jabs.size.to_s

        [status, headers, jabs]
      end
    end
  end
end