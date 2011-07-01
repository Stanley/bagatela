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

root = File.join File.dirname(__FILE__),'..'
# Current git revision
rev = File.read File.join(root,'.git','refs','heads','master')    
# Latest tag name
tag = `git tag --contains master | head -n 1`                
# Tag name if master is tagged, commit hash otherwise
VERSION = tag != '' && File.read(File.join(root,'.git','refs','tags',tag)) == rev ? tag : rev[0..5]
