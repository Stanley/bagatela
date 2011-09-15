require 'msgpack'
require 'unicode'
require 'jruby/profiler'

module Bagatela
  module Graph
    class Import

      def self.nodes!(db, group=false, inserter=nil)
        inserter = Neo4j::Batch::Inserter.new unless context = !!inserter
        Hash[nodes(db,group).map do |id, stop|
          [id, inserter.create_node(stop, group ? Hub : Stop)]
        end].tap{ inserter.shutdown unless context }
      end

      # Create and save relationships in Neo4j databse.
      #
      # db    - [String]:
      # date  - [Time]:
      #
      # Returns Array of Graph::Connections
      def self.relationships!(db, group_stops=false, date=Time.now)

        inserter = Neo4j::Batch::Inserter.new
        stops = nodes!(db, group_stops, inserter)

        # Hash of connections
        connections = {}

        # Identification of previous stop (or hub)
        from = nil
        # Remember previous line to determine if it has changed
        prev_line = nil
        # A Timetable which is one stop ahead of current timetable.
        next_timetable = nil
        # Iterate _backwards_, that is against the line's direction;
        # from the last timetable to the first.
        Resources::Timetable.view(db, :by_source, {:descending => true}).each do |timetable|

          to = if prev_line.nil? || prev_line != timetable['line']
            puts "---#{timetable['line']}---"
            # Line has changed; current timetable is last in a row.
            next_timetable = nil
            prev_line = timetable['line']
            # Line's destination.
            #stops[timetable.destination]
            timetable.destination
          else
            # Previous stop becomes our next stop.
            from
          end || raise("#{timetable.destination} #{timetable.destination.encoding}")
          
          # Current stop (or hub).
          from = timetable.stop_id #stops[timetable.stop_id] || raise(timetable.stop_id)
          #puts "#{timetable.stop_id} (#{timetable.stop_id.encoding})"

          # It will happen when we don't provide *stop_ids* and there are
          # two stops named the same in a row. Its rare situation but it
          # happens in Krakow for example.
          if from == to
            id = "#{timetable.stop_id}+1"
            to = id #stops[id] ||= Graph::Hub.new(name:id, lat:to[:lat], lon:to[:lon])
          end

          # Get or create relationship between *from* and *to* stops
          connections[from] ||= {}
          unless connection = connections[from][to] #from.rels(:connects).outgoing.to_other(to).first
            connection = {'length' => 0} #Graph::Connection.new(:connects, from, to)
            # Push newly created connection to output array.
            connections[from][to] = connection
          end
          # Add rides from current timetable
          connection['rides'] = (connection['rides'] || {}).
            merge(timetable.rides(date, next_timetable))
          # Current timetable becomes next
          next_timetable = timetable
        end

        connections.each_pair do |from_id, to_ids|
          from = stops[from_id]
          to_ids.each do |to_id, connection|
            to = stops[to_id]
            connection['rides'] = MessagePack.pack(connection['rides'])
            inserter.create_rel(:connects, from, to, connection, Graph::Connection)
          end
        end
        inserter.shutdown
        connections #.values.map{|values| values.values}.flatten
      end

      private

      # Create nodes in Neo4j databse.
      #
      # db -
      # group - [true or false]: 
      #
      # Returns Hash of pairs: self.id => Graph::Hub
      def self.nodes(db, group)
        Hash[group ? hubs(db) : stops(db)]
      end

      def self.stops(db)
        Resources::Stop.view(db, :by_name, :reduce=>false).map do |doc|
          id = doc['finish'] ? Unicode.upcase(doc['name']) : doc['_id']
          stop = doc['location'] || {}
          stop['name'] = doc['name']
          [id, stop]
        end
      end

      def self.hubs(db)
        Resources::Stop.view(db, :by_name, :group_level=>1).map do |doc|
          id = Unicode.upcase(doc['_key'][0]).force_encoding("UTF-8")
          #hub = Hub.new(doc['location'])
          #hub[:name] = doc['_key'][0].force_encoding("UTF-8")
          #hub[:source] = doc['docs'].map{|id| "#{db}-#{id}"} if doc['docs']
          [id, {'name' => doc['_key'][0].force_encoding("UTF-8")}.merge(doc['location'] || {})]
        end
      end

    end
  end
end
