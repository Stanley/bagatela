require 'priority_queue'

class AStar
  def initialize(start, stop, time, discriminant)
    # Find starting and ending hubs by name using lucene index. Raise 404 if either of them is not found.
    @start_from = Hub.find(:name=>start.downcase)
    @finish_at = Hub.find(:name=>stop.downcase)
    @time = time
    @charge = 'by_' + discriminant
    raise NotFound, "resource_not_found" if @start_from.empty? or @finish_at.empty?
  end

  def each_run(&block)

    queue = PriorityQueue.new
    @start_from.each do |start|
      @finish_at.each do |finish|
        queue.add start.send(@charge, finish), {:stops=>[start], :cost=>0, :time=>@time.hour*60+@time.min, :track=>[]}
      end
    end

    while not queue.empty?

      # Choose node which is the closest to the destination
      node = queue.next
      # List of visited stops
      stops = node[:stops]
      # Node arrival time
      time = node[:time]   
      # Array of departures and duration times. Used to recreate the journey.
      times = node[:track]  
      # Current location
      hub = stops.last

      # Iterates thorough all connections
      hub.connections_rels.each do |connection|

        # Cost, departure time and trip duration to the next stop
        cost, dep, dur = connection.send(@charge, time) || next
        # Our next stop
        other_hub = connection.end_node

        step = {:stops  => stops + [ other_hub ],
                :cost   => cost + node[:cost],
                :time   => dep + dur,
                :track  => times + [ [dep, dur] ]}

        if @finish_at.include?(other_hub)
          step[:stops].each_cons(2).zip(step[:track]) do |pair, time|
            # |departure, stop_a, duration, stop_b|
            midnight = @time.to_i/(60*60*24)*(60*60*24) - @time.gmt_offset
            block.call(Time.at(midnight + time[0]*60), pair[0].name, time[1], pair[1].name)
          end; return
        else
          @finish_at.each do |finish|
            # Calculate heuristic and add node to the queue
            queue.add other_hub.send(@charge, finish) + step[:cost], step
          end
        end
      end
    end    
  end
end
