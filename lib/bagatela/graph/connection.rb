require 'msgpack'

module Neo4j::TypeConverters
  class HashConverter
    class << self
      def convert?(type)
        type == Hash
      end
      def to_java(val)
        (val || {}).to_msgpack
      end
      def to_ruby(val)
        val ? MessagePack.unpack(val.encode "ASCII-8BIT") : {}
      end
    end
  end
end

module Bagatela
  module Graph
    # Connection between hubs can not be described by one polyline (can connect many-to-many stops) but an average length of all this polylines is used to determine cost of connection.
    class Connection
      include Neo4j::RelationshipMixin

      # Distance in meters.
      property :length
      # Hash of rides where the key is departure time (minutes from midnight) and
      # the value is hash with *line* and ride's *duration* time properties.
      property :rides, :type=>Hash

      # Returns nil if there are no more runs
      # Otherwise return cost (that is waiting time + trip time), departure time and trip time
      #def by_time(time)
        #dep, dur = next_run(time) || next
        #[dep-time+dur, dep, dur]
      #end

      ## Returns nil if there are no more runs
      #def by_dist(time)
        #dep, dur = next_run(time) || next
        #[cost || start_node.by_dist(end_node), dep, dur]
      #end

      #private

      ## Finds next run and returns its departure time and waiting time
      #def next_run(time) 
        ## TODO: do not use json!
        #JSON.parse(timetables).sort.
          #map{|dep, _| [dep.to_i, _]}.
          #find{|dep, _| dep.to_i >= time}
      #end
    end
  end
end
