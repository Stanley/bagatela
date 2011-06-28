require 'rake'
require 'restclient'
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
  task :import do
  end
end

namespace :couchdb do 

  desc "Push Couchdb views"
  task :views, [:db] do |t, args|
    designs = File.read './views/designs.json'
    RestClient.post CONFIG['couch'] +'/'+ args[:db] +'/_bulk_docs', designs, :content_type => :json, :accept => :json do |resp|; end
  end

  desc "Create ES couchdb river"
  task :river, [:db] do |t, args|
    river = YAML::load File.read(File.join(File.dirname(__FILE__), 'config', 'river.yaml'))
    river['couchdb']['host'], river['couchdb']['port'] = CONFIG['couch'].split(':')
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
