class Stop
  include Neo4j::NodeMixin
  property :name, :lat, :lng, :location

  has_n(:transfers).to(Stop)
  has_n(:connections).to(Stop).relationship(Polyline)
  has_n(:departures).to(Run)

  index :name, :tokenized => true

  def to_s
    "Stop #{self.name}"
  end
end