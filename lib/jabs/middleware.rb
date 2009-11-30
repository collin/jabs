module Jabs
  module Rack 
    
    def self.mount(rack_builder, mount_pount)
      rack_builder.map(mount_pount) do
        run (lambda do |env|
          source = %w{
            jquery/jquery-1.3.2.js
            jquery/jquery.event.drag-1.5.js
            jquery/jquery.event.drop-1.2.js
            jquery/jquery.focus_and_blur.js
          }.map{|path| (Jabs.root+path).read }.join("\n")
          
          [200, {'Content-Type'=> 'text/javascript'}, source]
        end)
      end
    end
        
    class Static < ::Rack::Static
      def initialize(app, options={})
        super(app, options)
        root = options[:root] || Dir.pwd
        @file_server = Jabs::Rack::File.new(root)
      end
    end
    
    class File < ::Rack::File
      def serving
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