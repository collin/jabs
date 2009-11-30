require 'fold'
require 'rack'
require 'johnson'
require 'pathname'

module Jabs
  
  def self.root
    @root ||= Pathname.new(__FILE__).dirname.expand_path
  end
  
  require root+'jabs/precompiler'
  require root+'jabs/engine'
  require root+'jabs/middleware'
  
  require root+'johnson/ext'
  include Johnson::Nodes
  
  def self.logger
    @logger ||= begin
      #TODO configurable logging
      logger       = Logger.new STDOUT
      logger.level = Logger::DEBUG
      logger.progname = "jabs"
      logger.info "Started Logging"
      logger
    end
  end
    
end
