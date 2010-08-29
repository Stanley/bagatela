require 'rubygems'
require 'sinatra'
require 'spec'
require 'spec/interop/test'
require 'rack/test'

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}

# set test environment
Sinatra::Base.set :environment, :test
Sinatra::Base.set :run, false
Sinatra::Base.set :raise_errors, true
Sinatra::Base.set :logging, false

require 'app/main'

Spec::Runner.configure do |config|
  config.before(:each) do
    Neo4j.stop
    FileUtils.rm_rf Neo4j::Config[:storage_path] # Dumps database
    FileUtils.rm_rf Lucene::Config[:storage_path] unless Lucene::Config[:storage_path].nil?
    Neo4j.start
    Neo4j::Transaction.new
  end

  config.after(:each) do
    Neo4j::Transaction.finish
    Neo4j.stop
  end
end
