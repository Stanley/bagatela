module Bagatela
  module Graph
    # Set of stops named the same. Passengers can transfer easily within hubs.
    class Hub
      include Neo4j::NodeMixin

      property :id, :lat, :lon
      index :id

      has_n(:connects).to(self).relationship(Connection)

      #R = 6371 * 1000   # Earth radius in meters
      #RAD = Math::PI / 180 # Converts degrees do radians

      ## Resturns distance in meters to given hub
      #def by_dist(hub)
        #a, b = [self.lat, self.lng], [hub.lat, hub.lng]
        #dLat = (b[0] - a[0]) * RAD
        #dLng = (b[1] - a[1]) * RAD

        #d = Math.sin(dLat / 2) ** 2 +
            #Math.cos(a[0] * RAD) * Math.cos(b[0] * RAD) *
            #Math.sin(dLng / 2) ** 2

        #R * 2 * Math.atan2(Math.sqrt(d), Math.sqrt(1-d))
      #end

      #def by_time(hub)
        ## estimated time to hub in minutes given average speed of 20km/h
        #by_dist(hub)/1000/20 *60 
      #end
    end
  end
end
