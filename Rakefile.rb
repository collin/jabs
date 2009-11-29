require 'rubygems'
require 'pathname'
require 'launchy'

__DIR__ = Pathname.new(__FILE__).dirname
$LOAD_PATH << __DIR__ unless $LOAD_PATH.include?(__DIR__)

task :default => "spec:all"

namespace :spec do
  task :default => :all

  task :prepare do 
    @specs= Pathname.glob(__DIR__ + "rspec" + "**"  + "*.rb").join(' ')
    p @specs
  end
  
  task :all => :prepare do
    system "spec #{@specs}"
  end
  
  task :doc => :prepare do
    system "spec #{@specs} --format specdoc"
  end
end

task :example do#=> "spec:all" do
  require 'lib/jabs'
  examples = __DIR__ + "examples"
  jabs = (examples + "input_with_default.js.jabs").read
  jabs_en   = Jabs::Engine.new(jabs)
  js   = jabs_en.render
  target = examples + "input_with_default.js"
  js_file = File.new(target, 'w')
  js_file.write(js)
  js_file.close

  haml = (examples + "layout.html.haml").read
  haml_en = Haml::Engine.new(haml)
  html = haml_en.render :example => target
  html_file = File.new("layout.html", 'w')
  html_file.write(html)
  html_file.close

  browser = Launchy::Browser.new
  browser.visit(target)
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "jabs"
    gemspec.summary = "Javascript Abstract Behavior Syntax"
    gemspec.description = "Inspiredby HAML, SASS and JABL by mr Hampton Catlin"
    gemspec.email = "collintmiller@gmail.com"
    gemspec.homepage = "http://github.com/collin/jabs"
    gemspec.authors = ["Collin Miller"]

    gemspec.add_dependency('fold', '0.5.0')
    gemspec.add_dependency('johnson', '1.1.2')
    gemspec.add_dependency('colored', '1.1')
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end