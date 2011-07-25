class Stop
  include Neo4j::NodeMixin

  property :id, :lat, :lon
  index :id

  has_n(:connections).to(Stop).relationship(Connection)
  has_n(:transfers).to(Stop).relationship(Transfer)

end
