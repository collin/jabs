require 'lib/jabs'
require 'pathname'

use Jabs::Rack::Static, :urls => '/jabs', :root => Pathname.new(__FILE__).dirname.expand_path
Jabs::Rack.mount(self, '/jquery')
map "/" do
  run lambda { |env| [200, {'Content-Type'=>'text/html'}, "JABS"] }
end

