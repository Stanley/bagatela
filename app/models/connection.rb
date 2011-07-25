##
# Connection between hubs can not be described by one polyline (can connect many-to-many stops) but an average length of all this polylines is used to determine cost of connection.
class Connection
  include Neo4j::RelationshipMixin

  property :cost        # distance in meters
  property :departures  # hash of departures where key is a time and value is pair: line and arrival time

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
