require 'rubygems'
require 'json'
require 'neo4j'
require 'picky-client'
require 'rest_client'
require File.join(File.dirname(__FILE__), 'exceptions')

# Set up query instance
Stops = Picky::Client::Full.new :host => 'localhost', :port => 8080, :path => '/stops/full'
Nodes = Picky::Client::Full.new :host => 'localhost', :port => 8080, :path => '/nodes/full'
Couch = RestClient::Resource.new 'http://localhost:5984/stops'

$: << File.join(File.dirname(__FILE__), '..', 'app', 'models')
require 'connection'
require 'hub'
require 'a_star'
