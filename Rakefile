#!/usr/bin/env jruby
# encoding: utf-8

require 'rake'
require 'restclient'
require 'unicode'
#require 'spec/rake/spectask'
require File.join(File.dirname(__FILE__), 'config', 'environment')

#task :default => :test
#task :test => :spec

#if !defined?(Spec)
  #puts "spec targets require RSpec"
#else
  #desc "Run all examples"
  #Spec::Rake::SpecTask.new('spec') do |t|
    #t.spec_files = FileList['spec/**/*.rb']
    #t.spec_opts = ['-cfs']
  #end
#end

namespace :neo4j do
  desc "Populate graph"
  task :import, [:db] do |t, args|

    require 'neo4j'
    db = CONFIG['couch'] +'/'+ args[:db]
    stops = {}

    Neo4j::Transaction.run do
      # Get all stops
      JSON.parse(RestClient.get db+'/_design/Stops/_view/by_name?group_level=1')['rows'].
        each do |row|
        location = row['value']['location']
        name = Unicode::upcase(row['key'].first)
        stops[name] = Neo4j::Node.new(location)
      end

      # Destination hub name
      destination = nil
      # Node from which we're adding connection
      from = nil

      # Get all timetables
      JSON.parse(RestClient.get db+'/_design/Timetables/_view/by_source?limit=200&descending=true')['rows'].
        map{|row| row['value']}.
        each do |timetable|
          # timetable's destination
          dest = Unicode::upcase((timetable['destination'] || timetable['route'].split('-').last).strip)
          timetable['stop'] = Unicode.upcase(timetable['stop'])

          to = destination === dest ? from : stops[dest]
          from = stops[timetable['stop']] # timetables['stop_id']

          puts "#{timetable['line']}\n" if destination != dest
          destination = dest

          if to == from
            plus_one = timetable['stop'] +"+1"
            unless from = stops[plus_one]
              # create new node
              from = stops[plus_one] = Neo4j::Node.new({}) # todo location
            end
          end

          puts "<- #{timetable['stop']} (#{from})"
          puts "ERROR: #{dest}" unless to
          
          # Get or create relationship between from and to stops
          unless connection = from.rels(:connections).outgoing.to_other(to).first
            connection = Neo4j::Relationship.new(:connections, from, to)
            connection['cost'] = 0
          end
          # add departures from current timetable
          connection['departures'] = "?"
        end
    end
  end
end

namespace :couchdb do 

  desc "Push Couchdb views"
  task :views, [:db] do |t, args|
    couch = CONFIG['couch'] +'/'+ args[:db]
    designs = File.read './views/designs.json'
    RestClient.post couch +'/_bulk_docs', designs, :content_type => :json, :accept => :json do |resp, req| 
      JSON.parse(resp).each do |status|
        if(status['error'] === 'conflict')
          p status
        end
      end
    end
  end

  desc "Create ES couchdb river"
  task :river, [:db] do |t, args|
    river = YAML::load File.read(File.join(File.dirname(__FILE__), 'config', 'river.yaml'))
    river['couchdb']['host'], river['couchdb']['port'] = CONFIG['couch'].match(/@(.+)\:(\d+)/)[1..2]
    river['couchdb']['db'] = river['index']['type'] = args[:db]
    RestClient.delete CONFIG['es'] +'/_river/couchdb' do |resp|; end
    RestClient.put CONFIG['es'] +'/_river/couchdb/_meta', river.to_json do |resp|; end
  end
end

desc "Create new index"
task :elasticsearch do
  RestClient.delete CONFIG['es'] +'/stops' do |resp|; end
  index = YAML::load(File.read(File.join(File.dirname(__FILE__), 'config', 'index.yaml'))).to_json
  RestClient.put CONFIG['es'] +'/stops', index do |resp|; end
end
