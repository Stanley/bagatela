require 'rake'
require 'spec/rake/spectask'

task :default => :test
task :test => :spec

if !defined?(Spec)
  puts "spec targets require RSpec"
else
  desc "Run all examples"
  Spec::Rake::SpecTask.new('spec') do |t|
    t.spec_files = FileList['spec/**/*.rb']
    t.spec_opts = ['-cfs']
  end
end

namespace :db do

  desc "Populate graph"
  task :import do
  end

end

namespace :couchdb do 

  desc "Push Couchdb views"
  task :views, [:db] do |t, args|
    require 'restclient'
    designs = File.read './views/designs.json'

    RestClient.post args[:db] +'/_bulk_docs', designs, :content_type => :json, :accept => :json
  end

end
