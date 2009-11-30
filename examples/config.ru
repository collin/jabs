require 'lib/jabs'
require 'pathname'
require 'sinatra'
require 'haml'
require 'sass'

class Example < Sinatra::Base
  set :views, Jabs.root+'../examples/views'

  %w{input_with_default drag_and_drop}.each do |part|
    get "/#{part}" do
      haml part.intern
    end
  end
end

use Jabs::Rack::Static, :urls => '/jabs', :root => Pathname.new(__FILE__).dirname.expand_path
Jabs::Rack.mount(self, '/jquery')
map("/examples") { run Example.new }

