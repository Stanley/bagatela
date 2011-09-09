module Bagatela
  module Graph
    module Search
      class Fast < Neo4j::Algo

        extend Forwardable

        def_delegators :execute_algo, :nodes,
                                      :relationships,
                                      :departure,
                                      :arrival

        def self.journey(options)
          from = options.delete :from
          to = options.delete :to
          new(from, to) do 
            @options = options
            AStar.new cost, estimation
          end
        end

        def execute_algo
          self.instance_eval(&@factory_proc).
            find_single_path(@from, @to, @options[:time])
        end

        private

        def cost
          # Time required to travel from rel.start_node to rel.end_node
          # including waiting time.
          #
          # rel - relation between two nodes
          # time - when we arrive on rel.start_node
          #
          # Returns [wait_time, ride_time] or nil
          lambda do |rel, time|
            next_run = rel.next_run(time) || return
            [next_run[0]-time, next_run[1]]
          end
        end

        def estimation
          # Distance in straight line between two given points
          #
          # node - first Hub
          # goal - second Hub
          #
          # Returns Float
          lambda do |node, goal|
            node.distance_to(goal)
          end
        end
         
      end
    end
  end
end
