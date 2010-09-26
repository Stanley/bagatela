require 'priority_queue'

class AStar
  def initialize(start, stop, time)
    # Find starting and ending hubs by name using lucene index. Raise 404 if either of them is not found.
    @start_from = Hub.find(:name=>start.downcase)
    @finish_at = Hub.find(:name=>stop.downcase)
    @time = time
    raise NotFound, "resource_not_found" if @start_from.empty? or @finish_at.empty?
  end

  def each_run(&block)

    queue = PriorityQueue.new
    @start_from.each do |start|
      @finish_at.each do |finish|
        queue.add(start.distance_to(finish), {:stops=>[start], :cost=>0, :time=>@time.hour*60+@time.min, :times=>[]})
      end
    end

    while not queue.empty?

      # Choose node which is the closest to the destination
      node = queue.next
      stops = node[:stops]
      time = node[:time]    # Node arrival time
      times = node[:times]  # Array of departures and duration times. Used to reconstruct the journey.
      hub = stops.last

      # Iterates thorough all connections
      hub.connections_rels.each do |connection|

        # Our next stop
        other_hub = connection.end_node
        # Cost so far
        cost = hub.distance_to(other_hub) + node[:cost]
        
        dep, dur = JSON.parse(connection._java_node.get_property('timetables')) \
          .sort.find{ |dep, _| dep.to_i >= time } || next

        step = {:stops  => stops + [other_hub],
                :cost   => cost,
                :time   => dep.to_i + dur.to_i,
                :times  => times + [[dep, dur].map{|x| x.to_i}]}

        if @finish_at.include?(other_hub)
          step[:stops].each_cons(2).zip(step[:times]) do |pair, time|
            # |departure, stop_a, duration, stop_b|
            midnight = @time.to_i/(60*60*24)*(60*60*24) - @time.gmt_offset
            block.call(Time.at(midnight + time[0]*60), pair[0].name, time[1], pair[1].name)
          end
          return
        else
          @finish_at.each do |finish|
            # Calculate heuristic and add node to the queue
            queue.add other_hub.distance_to(finish) + cost, step
          end
        end
      end
    end    
  end
end