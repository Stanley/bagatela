module Bagatela
  module Graph
    module Search
      class AStar

        #import org.neo4j.graphalgo.impl.util.WeightedPathImpl

        #
        #
        # cost_evaluator - 
        # estimate_evaluator - 
        def initialize(cost_evaluator, estimate_evaluator)
          @cost_evaluator = cost_evaluator
          @estimate_evaluator = estimate_evaluator
        end

        #
        #
        # start
        # goal
        # time
        #
        # Returns Path
        def find_single_path(start, goal, time)

          @start = start || raise("You must specify start node")
          @goal  = goal  || raise("You must specify end node")

          # The map of navigated nodes.
          @came_by = {}               
          # Cost from each node along best known path.
          @cost_so_far = {start.id => time.hour*60+time.min}  
          # @estimate_evaluator.call(start, goal)
          @h_score = {start => 0}     
          @waiting_time = {}

          closedset = []     # The set of nodes already evaluated.
          openset = [start]  # The set of tentative nodes to be evaluated, initially containing the start node

          # The node in openset having the lowest f_score[] value
          while node = openset.min_by{|x| f_score[x]}
            return to_path if node == @goal

            openset.delete(node) # remove node from openset
            closedset.push(node.id)  # add node to closedset
            puts "- #{node[:name]}(#{f_score[node]}) out of #{openset.size}"
            node.rels.outgoing.each do |rel|

              y = rel.end_node
              next if closedset.include?(y.id)

              wait, ride = @cost_evaluator.call(rel, @cost_so_far[node.id]) || next

              # arrival time
              tentative_cost = @cost_so_far[node.id] + wait + ride
              @waiting_time[node.id] = wait

              if not openset.any?{|x| y.id == x.id} #include?(y)
                openset.push(y)
                tentative_is_better = true
              elsif tentative_cost < @cost_so_far[y.id] #@cost_so_far[y]
                tentative_is_better = true
              else
                tentative_is_better = false
              end

              if tentative_is_better
                @came_by[y.id] = rel
                @cost_so_far[y.id] = tentative_cost
                # speed so far
                speed = @start.distance_to(y) / (tentative_cost-(time.hour*60+time.min))
                # estimated arrival time in minutes (distance / speed)
                @h_score[y] = @estimate_evaluator.call(y, @goal) / speed
              end
              #puts "#{y[:name]}: #{cost} => #{tentative_cost/60}:#{tentative_cost%60} (#{f_score[y]})"
            end
          end
          raise ConnectionNotFound
        end

        private

        def f_score
          lambda{|node| @cost_so_far[node.id] + @h_score[node]}
        end

        # Returns Journey
        def to_path
          connections = {}
          current = @goal
          while rel = @came_by[current.id]
            current = rel.start_node
            departure = @cost_so_far[current.id] + @waiting_time[current.id]
            connections[departure] = rel
          end
          Journey.new(@start, connections)
        end

      end
    end
  end
end
