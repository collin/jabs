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

task :cleanup do 
  Dir.glob("**/*.*~")+Dir.glob("**/*~").each{|swap|FileUtils.rm(swap, :force => true)}
end
