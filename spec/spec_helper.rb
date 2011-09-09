require 'rspec'
require 'rack/test'
require 'lib/bagatela'

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  # Using Mocha; a mocking and stubbing library.
  config.mock_with :mocha

  Neo4j::Config[:storage_path] = "db/test/#{Time.now.strftime('%Y-%m-%d')}"

  #config.before(:each) do
    #FileUtils.rm_rf Neo4j::Config[:storage_path] # Dumps database
    #Neo4j.start
  #end

  #config.after(:each) do
    #Neo4j.shutdown
  #end
end
