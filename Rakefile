#!/usr/bin/env jruby
# encoding: utf-8

require 'rake'
require 'restclient'
#require 'spec/rake/spectask'
require 'lib/bagatela'

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
  desc "Create graph from static documents"
  task :import, [:db] do |t, args|

    Bagatela::Graph::Import.relationships!(args[:db])

    #require 'neo4j'
    #db = CONFIG['couch'] +'/'+ args[:db]
    #stops = {}

    #Neo4j::Transaction.run do
      ## Get all stops
      #JSON.parse(RestClient.get db+'/_design/Stops/_view/by_name?group_level=1')['rows'].
        #each do |row|
        #location = row['value']['location']
        #name = Unicode::upcase(row['key'].first)
        #stops[name] = Neo4j::Node.new(location)
      #end

      ## Destination hub name
      #destination = nil
      ## Node from which we're adding connection
      #from = nil

      ## Get all timetables
      #JSON.parse(RestClient.get db+'/_design/Timetables/_view/by_source?limit=200&descending=true')['rows'].
        #map{|row| row['value']}.
        #each do |timetable|
          ## timetable's destination
          #dest = Unicode::upcase((timetable['destination'] || timetable['route'].split('-').last).strip)
          #timetable['stop'] = Unicode.upcase(timetable['stop'])

          #to = destination === dest ? from : stops[dest]
          #from = stops[timetable['stop']] # timetables['stop_id']

          #puts "#{timetable['line']}\n" if destination != dest
          #destination = dest

          #if to == from
            #plus_one = timetable['stop'] +"+1"
            #unless from = stops[plus_one]
              ## create new node
              #from = stops[plus_one] = Neo4j::Node.new({}) # todo location
            #end
          #end

          #puts "<- #{timetable['stop']} (#{from})"
          #puts "ERROR: #{dest}" unless to
          
          ## Get or create relationship between from and to stops
          #unless connection = from.rels(:connections).outgoing.to_other(to).first
            #connection = Neo4j::Relationship.new(:connections, from, to)
            #connection['cost'] = 0
          #end
          ## add departures from current timetable
          #connection['departures'] = "?"
        #end
    #end
  end
end

namespace :couchdb do 

  desc "Push Couchdb views"
  task :views, [:db] do |t, args|

    db = "#{Bagatela::Resources::COUCHDB}/#{args[:db]}"
    headers = {:content_type => :json, :accept => :json}
    # Create database if it doesn't exist; ignore errors
    RestClient.put db, nil do |resp|; end 

    JSON.parse(File.read('./views/designs.json').
      # We have to remove new lines from strings in order to get valid JSON
      gsub(/(\"[^\"]+\")/){|str| str.gsub("\n",'\n') })['docs'].
      each do |doc|
        # Get previous revison and check if there are any changes
        old = JSON.parse(RestClient.get("#{db}/#{doc['_id']}"){|resp|; resp })
        doc.merge!({'_rev' => old.delete('_rev')}) if old['_rev']
        # Create or update document
        RestClient.post db, doc.to_json, headers unless doc == old
    end

  end

  desc "Create ES couchdb river"
  task :river, [:db] do |t, args|
    yaml = File.join(File.dirname(__FILE__), 'config', 'elasticsearch', 'river.yaml')
    river = YAML::load File.read(yaml)
    river['couchdb']['host'], river['couchdb']['port'] = CONFIG['couch'].match(/@(.+)\:(\d+)/)[1..2]
    river['couchdb']['db'] = river['index']['type'] = args[:db]
    RestClient.delete CONFIG['es'] +'/_river/couchdb' do |resp|; end
    RestClient.put CONFIG['es'] +'/_river/couchdb/_meta', river.to_json do |resp|; end
  end
end

desc "Create new index"
task :elasticsearch do
  RestClient.delete CONFIG['es'] +'/stops' do |resp|; end
  yaml = File.read(File.join(File.dirname(__FILE__), 'config', 'elasticsearch', 'index.yaml'))
  index = YAML::load(yaml).to_json
  RestClient.put CONFIG['es'] +'/stops', index do |resp|; end
end
