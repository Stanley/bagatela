Given /^an empty graph "([^"]*)"$/ do |database|
  Neo4j::Config[:storage_path] = database
  Neo4j::Transaction.run do
    Neo4j.all_nodes.each do |node|
      node.del unless node.id == 0 # reference node must exist
    end
  end
end

Given /^the following nodes:$/ do |resources|
  Neo4j::Transaction.run do
    @nodes = {}
    resources.hashes.each do |resource|
      id = resource.delete '@id'
      resource['lat'] = resource['lat'].to_f
      resource['lon'] = resource['lon'].to_f
      @nodes[id] = Neo4j::Node.new resource
    end
  end
end

Given /^the following "([^"]*)" relationships:$/ do |type, resources|
  Neo4j::Transaction.run do
    @relationships = {}
    resources.hashes.each do |resource|
      id = resource.delete '@id'
      from = resource.delete '@start_node'
      to = resource.delete '@end_node'
      resource['rides'] = MessagePack.pack(eval(resource['rides']))
      @relationships[id] = Neo4j::Relationship.new(type, @nodes[from], @nodes[to], resource)
    end
  end
end
