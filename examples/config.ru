require 'lib/jabs'
require 'pathname'

puts Pathname.new(__FILE__).dirname.expand_path+'src'
puts "OF"

use Jabs::Rack::Static, :urls => '/src', :root => Pathname.new(__FILE__).dirname.expand_path
run lambda { |env|
  [200, {'Content-Type'=>'text/html'}, "JABS"]
}