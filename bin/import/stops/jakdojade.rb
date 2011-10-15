#!/usr/bin/env ruby

require 'json'
require 'rest_client'
require 'couchrest'
require 'time'

db = CouchRest.database "http://localhost:5984/#{ARGV[0]}" # TODO: read it from config/database
all = JSON.parse($stdin.read[4..-3].sub('].concat([',',').sub('],[',','))
a, b, stops, x, y = all.slice!(-5..-1)

all.each_slice(25) do |slice|
  index = slice[11]
  type = stops[slice[10]-1]
  next unless ['bus','tram'].include?(type)

  doc = {type: 'Stop', updated_at: Time.new.utc.xmlschema, location: {}}
  doc[:location][:lat], doc[:location][:lon] = slice[4..5]
  doc[:address] = (index === 0 ? stops[slice[22]-1] : stops[index-1]).force_encoding('UTF-8')
  doc[:name] =  stops[slice[17]-1].force_encoding('UTF-8')
  doc[:operates] = [type]
 
  db.save_doc doc
end
