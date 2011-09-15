#!/usr/bin/env ruby
# encoding: UTF-8

require 'time'
require 'nokogiri'
require 'rest_client'
require 'couchrest'

db = CouchRest.database 'http://localhost:5984/kr' # TODO: read it from config/database
xml = Nokogiri.XML RestClient.get('http://www.mpk.krakow.pl/wyszukiwarka/common/stop_map.php')

db.view("Stops/by_name", :reduce=>false) do |doc|
  db.delete_doc doc['value']
end

xml.root.xpath("s").each do |stop|
  doc = {type: 'Stop', updated_at: Time.new.utc.xmlschema, location: {}}
  doc['name'] = stop.xpath('n').text.strip.force_encoding("UTF-8")
  doc[:location]['lat'] = stop.xpath('t').text.to_f
  doc[:location]['lon'] = stop.xpath('g').text.to_f

  db.save_doc doc
end
