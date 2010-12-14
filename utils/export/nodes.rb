require File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment')
require 'couchrest'

couch = CouchRest.database!("http://127.0.0.1:5984/krak")
f = File.new 'stops.csv', 'w+'
f << "id,name\n"
hash = {}
FileUtils.rm_rf Neo4j::Config[:storage_path] # Dumps database
Neo4j.start

Neo4j::Transaction.run do
  # Get all stops and save as nodes
  couch.view("Stop/by_name", :include_docs=>true)['rows'].
    map{|row| row['doc']}.
    group_by{|stop| stop['name']}.
    each_pair do |name, stops|
      # Stops which belong to one hub. Will be saved as one node
      # Avg. position
      lat = lng = 0
      stops.each do |stop|
        lat += stop['lat']
        lng += stop['lng']
      end
      node = Hub.new(:name => stops.first['name'], :lat => lat/stops.size, :lng => lng/stops.size)
      f << [node.neo_id, node.name].join(',') + "\n"
  end
end

