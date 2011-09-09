module Bagatela
  module Graph
    # Set of stops named the same. Passengers can transfer easily within hubs.
    class Hub
      include Neo4j::NodeMixin
      include Resource

      property :lat, :lon, :source
      index :source

      has_n(:connects).to(self).relationship(Connection)

      R = 6371 * 1000      # Earth radius in meters
      RAD = Math::PI / 180 # Converts degrees do radians

      # Distance in meters to given point
      #
      # to - Hub, Stop or any Hash with 'lat' and 'lon' properites
      #
      # Returns Float
      def distance_to(to)
        a, b = [self['lat'], self['lon']], [to['lat'], to['lon']]
        dLat = (b[0] - a[0]) * RAD
        dLng = (b[1] - a[1]) * RAD

        d = Math.sin(dLat / 2) ** 2 +
            Math.cos(a[0] * RAD) * Math.cos(b[0] * RAD) *
            Math.sin(dLng / 2) ** 2

        R * 2 * Math.atan2(Math.sqrt(d), Math.sqrt(1-d))
      end

    end
  end
end
