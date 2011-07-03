require 'uri'
require 'json'
require 'rest_client'
require 'rake'

Rake.application.init
Rake.application.load_rakefile

API = 'http://localhost:8000/'
