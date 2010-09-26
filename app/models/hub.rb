##
# Set of stops named the same. Passengers can transfer easily within hubs.
class Hub
  include Neo4j::NodeMixin

  property :name, :lat, :lon

  has_n(:connections).to(Hub).relationship(Connection)

  index :name, :tokenized => true

  R = 6371 * 1000   # Earth radius in meters
  RAD = Math::PI / 180 # Converts degrees do radians

  def to_s
    "Hub #{self.name}"
  end

  def distance_to(hub)
    a, b = [self.lat, self.lon], [hub.lat, hub.lon]
    dLat = (b[0] - a[0]) * RAD
    dLon = (b[1] - a[1]) * RAD

    d = Math.sin(dLat / 2) ** 2 +
        Math.cos(a[0] * RAD) * Math.cos(b[0] * RAD) *
        Math.sin(dLon / 2) ** 2

    R * 2 * Math.atan2(Math.sqrt(d), Math.sqrt(1-d))
  end
end
