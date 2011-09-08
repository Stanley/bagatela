require 'uri'
require 'json'
require 'msgpack'
require 'rest_client'
require 'rake'

require 'app/main'
require 'rack/test'

# Set test environment
Sinatra::Base.set :environment, :test
Sinatra::Base.set :run, false
Sinatra::Base.set :logging, false

Rake.application.init
Rake.application.load_rakefile

API = 'http://localhost:8000'
