require 'rubygems'
#require 'neo4j'
require 'yaml'
require 'json'
require File.join(File.dirname(__FILE__), 'exceptions')

#$: << File.join(File.dirname(__FILE__), '..', 'app', 'models')
#require 'connection'
#require 'hub'
#require 'a_star'

config = YAML::load File.read File.join(File.dirname(__FILE__), 'database.yaml')
CONFIG = config[ENV['RACK_ENV'] || "development"]
