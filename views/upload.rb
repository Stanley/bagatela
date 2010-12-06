require 'rubygems'
require 'couchrest'

db = RestClient::Resource.new 'http://localhost:5984/kr'

%w{Timetable Stop}.each do |file|
  view = File.join(File.dirname(__FILE__), file.downcase + '.json')
  db['_design/'+file].put File.read(view), :content_type => 'application/json'
end
