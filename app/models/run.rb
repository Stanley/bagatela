class Run
  include Neo4j::NodeMixin

  property :time, :type => Array

  has_one(:connection).to(Run)
end