#!/usr/bin/env jruby
# encoding: utf-8

require 'rake'
require 'yaml'
require 'json'
require 'restclient'

require './bin/import/stops/jakdojade'
#require 'spec/rake/spectask'

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

config_file = File.join(File.dirname(__FILE__), 'config', 'database.yaml')
config = YAML.load_file(config_file)['development']

desc "The same as couchdb:views"
task :couchdb, [:db] => 'couchdb:views'

namespace :couchdb do 

  desc "Create database if it doesn't exist"
  task :initialize, [:db] do |t, args|
    db = config['couchdb'] + args[:db]
    RestClient.put db, nil do |resp|
      if resp.code == 201 # Import stops
        pwd = File.dirname(__FILE__)
        path = "#{pwd}/config/cities/#{args[:db]}.json"
        # Execute proper external script
        Dir.chdir("#{pwd}/bin/import/stops")
        source, city = JSON.parse(File.read path)['stops']
        case source
        when 'mpk.krakow'
          `ruby mpk_krakow.rb`
        when 'kzkgop'
          `node kzkgop.js #{db}`
        when 'jakdojade'
          JakDojade.save!(db, `node jakdojade.js #{city}`)
        else
          raise 'Unknown source'
        end
      end
    end 
  end

  desc "Push all design documents from views/ to CouchDB"
  task :views, [:db] => :initialize do |t, args|

    db = config['couchdb'] + args[:db]
    headers = {:content_type => :json, :accept => :json}

    JSON.parse(File.read("#{File.dirname(__FILE__)}/views/designs.json").
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
