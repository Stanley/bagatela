require 'json'
require 'neo4j'
require File.join(File.dirname(__FILE__), 'exceptions')

Lucene::Config[:store_on_file] = true
Lucene::Config[:storage_path] = "db/lucene"

$: << File.join(File.dirname(__FILE__), '..', 'app', 'models')
Dir.glob(File.join(File.dirname(__FILE__), '..', 'app', 'models', '*.rb')){|lib| require File.basename(lib, '.*')}