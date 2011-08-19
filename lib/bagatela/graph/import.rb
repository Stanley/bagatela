require 'unicode'

module Bagatela
  module Graph
    class Import

      # Saves created nodes in Neo4j databse.
      #
      # See: nodes
      def self.nodes!(db)
        Neo4j::Transaction.run do
          nodes(db)
        end
      end
      
      # Saves created relationships in Neo4j databse.
      #
      # See: relationships
      def self.relationships!(db, date=Time.new)
        Neo4j::Transaction.run do
          relationships(db, date)
        end
      end

      private

      # Returns Hash of pairs: self.id => Graph::Stop(s)
      def self.nodes(db)
        Hash[Resources::Stop.view(db, :by_name, :group_level=>1).map do |doc|
          id = doc['_id'] || Unicode.upcase(doc['_key'][0]).force_encoding("UTF-8")
          [id, Hub.new(id:id)]
        end]
      end

      #
      #
      # db    - [String]:
      # date  - [Time]:
      #
      # Returns Array of Graph::Connections
      def self.relationships(db, date=Time.now)
        stops = nodes(db)
        # Array of connections
        output = []
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
            stops[timetable.destination]
          else
            # Previous stop becomes our next stop.
            from
          end || raise("#{timetable.destination} #{timetable.destination.encoding}")
          
          # Current stop (or hub).
          from = stops[timetable.stop_id] || raise(timetable.stop_id)
          puts "#{timetable.stop_id} (#{timetable.stop_id.encoding})"

          # It will happen when we didn't provide *stop_ids* and there are
          # two stops named the same in a row.  Its rare situation but it
          # happens in Krakow for example.
          if from == to
            id = "#{timetable.stop_id}+1"
            to = stops[id] ||= Graph::Hub.new(id:id)
          end

          # Get or create relationship between *from* and *to* stops
          unless connection = from.rels(:connects).outgoing.to_other(to).first
            connection = Graph::Connection.new(:connects, from, to)
            connection.length = 0
            # Push newly created connection to output array.
            output.push connection
          end
          # Add rides from current timetable
          connection.rides = (connection.rides || {}).
            merge(timetable.rides(date, next_timetable))
          # Current timetable becomes next
          next_timetable = timetable
        end
        output
     end

    end
  end
end
