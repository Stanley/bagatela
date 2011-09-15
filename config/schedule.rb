every :day, :at=>'0 am' do

  root = File.absolute_path "#{File.dirname(__FILE__)}/.."
  cities = "#{root}/config/cities/"
  Dir.foreach(cities) do |conf|
    next unless match = conf.match(/([a-z]+)\.json$/) and code = match[1]
    #json = JSON.parse(File.read(file))
    #couchdb = couch + json['code']

    # Create database if it doesn't exists, create or update design documents
    # and import stops.
    rake "couchdb[#{code}]"

    # Import timetables.
    pigeons = File.join(root,'bin','import','timetables','pigeons.js')
    command "node --use-http2 #{pigeons} #{cities+conf}"

    # Create city graph based on imported timetables.
    runner "Bagatela::Graph::Import.relationships!('#{code}', true)"
  end
end
