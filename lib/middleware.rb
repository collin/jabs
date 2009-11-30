require 'rack'

module Jabs
  class Middleware < Rack::File
    def serving
      @path += ".jabs" unless @path[/\.jabs$/]
      status, headers, body = *super
      return [status, headers, body] unless status == 200
      headers['Content-Type'] = 'text/javascript'
      [status, headers, Jabs::Engine.new(body).render]
    end
  end
end