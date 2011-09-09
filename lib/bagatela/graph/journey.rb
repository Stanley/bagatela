module Bagatela
  module Graph
    class Journey #< PathImpl

      include Enumerable
      extend Forwardable

      attr_reader :start
      def_delegators :relationships, :each, :length

      def initialize(start, departures)
        @start = start
        @departures = departures.sort
      end

      #def total_length
        #relationships.reduce(0) do |sum,(time,rel)|
          #sum + rel.length 
        #end
      #end

      #def transfers
      #end

      #def departure
        #Time.parse(@departures.keys.min)
      #end

      def departures_details
        Hash[@departures.map do |min, connection|
          ride = connection.rides[min]
          ["#{"%02d" % (min/60)}:#{"%02d" % (min%60)}", ride.merge(relationship: connection.uri)]
        end]
      end

      def arrival
        db = Neo4j::Config[:storage_path]
        arrival = relationships.last.next_run(@departures.last.first).reduce(:+)
        Time.utc(*db.split(/\/|-/)[-3..-1], arrival/60, arrival%60)
      end

      def nodes
        [start] + relationships.map{|rel| rel.end_node}
      end

      def relationships
        @departures.map{|key, val| val}
      end

      # For debugging purposes
      #
      # Returns String
      def to_s
        "TODO"
      end

    end
  end
end
