require 'rspec'
require 'rack/test'
require 'lib/bagatela'

# set test environment
Sinatra::Base.set :environment, :test
Sinatra::Base.set :run, false
Sinatra::Base.set :logging, false

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  # Using Mocha; a mocking and stubbing library.
  config.mock_with :mocha

  #config.before(:each) do
    #FileUtils.rm_rf Neo4j::Config[:storage_path] # Dumps database
    #Neo4j.start
  #end

  #config.after(:each) do
    #Neo4j.shutdown
  #end
end
