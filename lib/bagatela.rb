# rubygems
require 'rubygems'

# stdlib
require 'yaml'

# 3rd party
require 'json'
require 'neo4j'
require 'chronik'

# internals
require './lib/bagatela/resources/resource'
require './lib/bagatela/resources/departures'
require './lib/bagatela/resources/line'
require './lib/bagatela/resources/table'
require './lib/bagatela/resources/timetable'
require './lib/bagatela/resources/stop'
require './lib/bagatela/resources/hub'

require './lib/bagatela/graph/resource'
require './lib/bagatela/graph/connection'
require './lib/bagatela/graph/transfer'
require './lib/bagatela/graph/hub'
require './lib/bagatela/graph/stop'
require './lib/bagatela/graph/import'

require './lib/bagatela/graph/journey'
require './lib/bagatela/graph/search/fast'
require './lib/bagatela/graph/search/astar'

# Monkey patch
class String
  def upcase
    force_encoding('UTF-8').
      to_java_string.
      to_upper_case.
      gsub(/\.([^\s])/, '. \1').
      gsub(/\s{2,}/, ' ')
  end
end
