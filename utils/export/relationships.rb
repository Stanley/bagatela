require File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment')
require 'couchrest'

couch = CouchRest.database!("http://127.0.0.1:5984/krak")
missing = []

Neo4j::Transaction.run do
  # Get all timetables and save as relations between stops
  couch.view("Timetable/by_line", :include_docs=>true)['rows'].
    map{|row| row['doc']}.
    group_by{|t| t['route'].split(' - ').last.split(/ |\./).map{|w| w.capitalize}.join(' ')}.
    each_pair do |destination, line|
      # .force_encoding("UTF-8").split(' ').map{|w| w.capitalize}.join(' ')
      line.each_cons(2) do |a, b|
        # Find beginning and ending
#        beginning = Hub.find(:name => a['stop'].strip).first
        beginning = Nodes.search(:query => a['stop'])[:allocations]. #Hub.find(:name=>start)
          inject([]){|ids, allocation| ids + allocation[4]}.  # get ids,
          map{|id| Neo4j::Node.load id }.first
#        ending = Hub.find(:name => b['stop'].strip).first
        ending = Nodes.search(:query => b['stop'])[:allocations]. #Hub.find(:name=>start)
          inject([]){|ids, allocation| ids + allocation[4]}.  # get ids,
          map{|id| Neo4j::Node.load id }.first

        if beginning == nil or ending == nil
          print "f"
          missing << (beginning.nil? ? a['stop'] : b['stop'])
          next
        elsif beginning == ending
          print "*"
          next
        else
          print "."
        end
        # create relation
        connection = beginning.connections.new ending
        connection.cost = length(a['polylines'][b['_id']]) if a['polylines']
        # TODO: change timetable format
        # connection.timetables = a['table'].force_encoding("UTF-8").to_json
timetables = {}
a['table']['Soboty'].each_pair{|hour,minutes| minutes.each{|min| timetables[hour*60+min] = 1}} # Wylicz czas przejazdu
        connection.timetables = timetables
        connection.line = a['line']
      end
    # Connect last timetable with destination
    a = line.last
#    beginning = Hub.find(:name => a['stop'].strip).first
    beginning = Nodes.search(:query => a['stop'])[:allocations]. #Hub.find(:name=>start)
      inject([]){|ids, allocation| ids + allocation[4]}.  # get ids,
      map{|id| Neo4j::Node.load id }.first
#    ending = Hub.find(:name => destination.strip).first
    ending = Nodes.search(:query => destination)[:allocations]. #Hub.find(:name=>start)
      inject([]){|ids, allocation| ids + allocation[4]}.  # get ids,
      map{|id| Neo4j::Node.load id }.first

    if beginning == nil or ending == nil
      print "F"
      missing << (beginning.nil? ? a['stop'] : destination)
      next
    elsif beginning == ending
      print "*"
      next
    else
      print "."
      b = ending._java_node
    end

    connection = beginning.connections.new ending
    connection.cost = length(a['polylines'][b['_id']]) if a['polylines']
    # TODO: make up timetable 
    # connection.timetables = a['table'].to_json
    connection.line = a['line']
  end
end
p missing

def length(polyline)
  return nil unless polyline
  polyline.each_cons(2).map do |a,b|
    dLat = (b[0] - a[0]) * Rad
    dLon = (b[1] - a[1]) * Rad

    d = Math.sin(dLat / 2) ** 2 +
        Math.cos(a[0] * Rad) * Math.cos(b[0] * Rad) *
        Math.sin(dLon / 2) ** 2

    R * 2 * Math.atan2(Math.sqrt(d), Math.sqrt(1-d))
  end.reduce(:+)
end
