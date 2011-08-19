class Transfer
  include Neo4j::RelationshipMixin
  property :cost # distance in meters
end
