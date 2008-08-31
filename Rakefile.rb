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

namespace :gem do
  task :version do
    @version = "0.0.1"
  end

  task :build => :spec do
    load __DIR__ + "jabs.gemspec"
    Gem::Builder.new(@jabs_gemspec).build
  end

  task :install => :build do
    cmd = "gem install jabs -l"
    system cmd unless system "sudo #{cmd}"
    FileUtils.rm(__DIR__ + "jabs-#{@version}.gem")
  end

  task :spec => :version do
    file = File.new(__DIR__ + "jabs.gemspec", 'w+')
    FileUtils.chmod 0755, __DIR__ + "jabs.gemspec"
    spec = %{
Gem::Specification.new do |s|
  s.name             = "jabs"
  s.date             = "2008-07-21"
  s.version          = "#{@version}"
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.has_rdoc         = false
  s.summary          = "A whitespace active min-language for writing javascript behaviors."
  s.authors          = ["Collin Miller"]
  s.email            = "collintmiller@gmail.com"
  s.homepage         = "http://github.com/collin/jabs"
  s.files            = %w{#{(%w(README Rakefile.rb) + Dir.glob("{lib,rspec,vendor}/**/*")).join(' ')}}
  
  s.add_dependency  "rake"
  s.add_dependency  "rspec"
  s.add_dependency  "collin-fold"
end
}

  @jabs_gemspec = eval(spec)
  file.write(spec)
  end
end
