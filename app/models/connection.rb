##
# Connection between hubs can not be described by one polyline (can connect many-to-many stops) but an average length of all this polylines is used to determine cost of connection.
class Connection
  include Neo4j::RelationshipMixin

  property :cost        # length in meters
  property :timetables  # every departure in direction
end
