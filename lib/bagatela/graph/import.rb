require 'msgpack'
require 'jruby/profiler'

module Bagatela
  module Graph
    class Import

      #
      #
      # db    - [String]:
      # date  - [Time]:
      #
      def initialize(db, group_stops=false)

        # 
        @db = db
        @group_stops = group_stops
        # All connections (arrays of: from, to, departures)
        @connections = Hash.new do |hash,key|
          length = 0
          hash[key] = {:length => length, :departures => {}}
        end
      end

      # Create and save relationships in Neo4j databse.
      #
      # Returns Array of Graph::Connections
      def relationships!(date=Time.now)
        
        Resources::Timetable.
          #view(@db, :by_line, {:descending => true, :reduce => false}).
          view(@db, :by_line, {:descending => true, :reduce => false, :startkey => '["2380"]', :endkey => '["0"]'}).
          group_by {|t| t['_key'][0]}.
          each_pair do |line, timetables| # each line

            timetables.
              group_by {|t| t['_key'][1]}.
              each_pair do |destination, timetables| # each destination

                puts "---#{line} (#{destination})---"

                timetables.each {|t| t.cache = t.table(date) }
                #weak_connections = []

                segments = segment(timetables) or return []

                #segments.each do |a|
                  #weakest = [0, nil]

                  #(segments.map{|x| x.first} - [a.first]).map do |b_table|

                    #p "+++ #{b_table} (#{a_table.standard_deviation(b_table)})"
                    
                    ##candidates.push [a_table.standard_deviation(b_table), b_table] unless a_table.standard_deviation(b_table) > 1
                    #score, avg, runs = a_table.standard_deviation(b_table)
                    ##puts "#{a.last.stop_id} -> #{b.first.stop_id} : #{score}"
                    #[score, avg, rand, b_table, runs] if runs

                    ### Na wszelki wypadek gdyby rozkład był pusty
                    ##next unless first && last
                    ### Sprawdź czy ostatni przystanek pierwszego odcinka należy do
                    ### zbioru do drugiego odcinka. Jeżeli tak, przerwij poszukiwania.
                    ###next([0,b]) if(a.include?(b.first))

                    ##score = (b_table.after(first) || next) - first + 
                            ##(b_table.after(last) || next) - last

                    ##raise "stop" unless score
                    
                  ## Choose the best matching segment.
                  #end.compact.min.tap do |score, mean, rand, table, match|
                    #if score
                      ##to = table
                      ## [from, to, std_deviation]
                      #pairs[a.last] = [table, [score, mean, rand]]
                      ## sprawdź czy `a` traci kursy
                      ## TODO: not the best place for this
                      #unless match.all? {|key,val| val['duration']}
                        #declining.push([a.last, match])
                      #end
                    #else
                      #pairs[a.last] = [destination.upcase, []]
                    #end
                  #end


                # 
                #pairs = Hash[segments.map{|a| [a.last,nil]}]

                # Join segments
                #puts "~~~ Joins ~~~"
                #segments.permutation(2).each do |a,b|
                  #if departures = a.last.departures(b.first)
                      #puts "#{a.last} > #{b.first} (#{departures.score})"
                    #if (pairs[a.last].nil? or pairs[a.last][1] > departures)
                      #pairs[a.last] = [b.first, departures]
                      ##puts "#{a.last} > #{b.first} (#{departures.score})"
                    #end
                  #end
                #end

                #
                #puts "~~~ ??? ~~~"
                #segments.each do |s|
                  ##p weak_connections
                  #weak_connections.each do |a,b,deps|
                    #next if s.include?(a)
                    ## TODO DRY!

                    ##score, avg, runs = a.standard_deviation(b)
                    #departures = a.departures(b)

                    ##score1, avg1, runs1 = s.last.standard_deviation(b)
                    #departures1 = s.last.departures(b)
                    ##p "?? #{s.last} > #{b} (#{departures.score} ? #{departures1.score})"
                    #smaller_size = [s.last.size, a.size].min
                    ##p smaller_size

                    #if !departures1.nil? and departures > departures1 and departures1.count{|key,val| val['duration']} == smaller_size

                      ##score2, avg2, runs2 = a.standard_deviation(s.first)
                      #departures2 = a.departures(s.first)
                      ##p "?? #{s.first} < #{a} (#{departures2.score})"

                      #if !departures2.nil? and departures > departures2 and departures2.count{|key,val| val['duration']} == smaller_size
                      
                        #puts "Removed connection: #{a} - #{b} (#{departures.score})"
                        #connections.delete [a,b,deps]

                        ##pairs[s.last] = [b, departures1]
                        #connections.push [s.last, b, departures1]
                        #puts "#{s.last} > #{b} (#{departures1.score})"

                        ##pairs[a] = [s.first, departures2]
                        #connections.push [a, s.first, departures2]
                        #puts "#{a} > #{s.first} (#{departures2.score})"

                      #end
                    #end
                  #end
                #end

              #end

              segments.map!{|x|[x,[]]} 
              segments.each do |segment, connections|

                #puts "\tSegment #{segment.first}..#{segment.last}"

                # Add line's departures to each relationship in segment.
                # Connect segment `segment` with its next destination.
                segment.each_cons(2).with_index do |(from, to), i|

                  # If connection is not possible or we could not determine
                  # duration of any run, split segment up.
                  if departures = from.departures(to, date) and
                    departures.all?{|key,val| val.has_key?('duration') }

                    #puts "#{from} -> #{to}"
                    #connections.push [from, to, departures]
                    connections.push departures
                  else 
                    p "splitting up!! before: #{to}"
                    # Split up segment where we couldn't connect nodes.
                    segments.push [segment.slice!((i+1)..-1), []] # TODO TEST !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                    break # Remaining tables don't belong to this segment any 
                          # more.
                  end
                  
                  #max = departures.map{|key,val| val['duration']}.max
                  #if weakest[0] < max
                    #weakest = [max, from, to, departures]
                  #elsif weakest[0] == max
                    #weakest = [0, nil]
                  #end
                #end

                #puts "Weakest connection comes after: #{weakest[1]}"
                #weak_connections.push weakest[1..-1] if weakest[0] > 0
                end
              end

              raise "stop (#{segments.size})" if segments.size > 5

              # debug
              segments.each do |segment,conn|
                puts segment.map{|x| x.to_s}.join(", ")
              end

              lines = segments.permutation.map do |permutation|
                begin
                copy = Marshal.load(Marshal.dump(permutation))
                Resources::Line.new copy, destination
                rescue Resources::SegmentsMismatch # TODO specs
                end
              end # The best line

              #lines.each do |line|
                #puts "#{line.score}: " + line.map {|from,to| from.to_s}.join(", ")
              #end

              l= lines.compact.min

        puts "\n#{l.score}: " + l.map {|from,to| "#{from}-#{to}"}.join(", ")
              
              p "-=-=-=-=-=-"
              # Dodaj połączenia do struktury `connections`
              l. 
                each do |from,to,departures|
                  #if to.nil?
                    #to = destination.upcase
                    #departures = from.departures
                  #end
                  puts "#{from} => #{to}"
                  #connections.push [from, to, departures]
              end

              merge l.to_a

            # TODO: create each connection in `connections`

              #p "~~~ #{declining.size}"
              #(connections.keys - connections.values.map{|x| x.keys}.flatten ).each do |y|
                #connections[y].each_pair do |to, connection|
                  #declining.each do |z, match|
                    #if connection['departures'].size == match.count{|key,val| val['duration'].nil?} 
                      
                      #p '-------------------', "#{z} -> #{y}"
                      #source_table = Resources::Table.new(match.select{|key,val| val['duration'].nil?}.keys)
                      #target_table = Resources::Table.new(connection['departures'].keys)
                      #next unless departures = source_table.departures(target_table)

                      #connections[z.to_s][y] = {'departures' => departures}
                      ##p ({'departures' => source_table.departures(target_table)}).inspect
                      ## TODO: delete_if val_duration.nil?
                      ##p "#{z} -> #{y}"
                    #end
                  #end
                #end
              end
          end

          # If any used node doesn't exist in database, create it.
          #(connections.keys + connections.values.map{|x| x.keys}.flatten ).uniq.each do |x|
            #if stops[x].nil?
              #puts "added #{x.inspect}: #{stops[x] = inserter.create_node({'name'=>x}, Hub)}"
            #end
          #end

          commit!

      end

      private

      # Retrives all nodes
      #
      # Returns Hash of pairs: self.id => Graph::Hub
      def nodes
        Hash[@group_stops ? hubs : stops]
      end

      def stops
        Resources::Stop.view(@db, :by_name, :reduce=>false).map do |doc|
          id = doc['finish'] ? doc['name'].upcase : doc['_id']
          stop = doc['location'] || {}
          stop['name'] = doc['name'] unless doc['name'].nil?
          [id, stop]
        end
      end

      def hubs
        Resources::Stop.view(@db, :by_name, :group_level=>1).map do |doc|
          id = doc['_key'][0].upcase
          #hub = Hub.new(doc['location'])
          #hub[:name] = doc['_key'][0].force_encoding("UTF-8")
          #hub[:source] = doc['docs'].map{|id| "#{db}-#{id}"} if doc['docs']
          [id, {'name' => doc['_key'][0]}.merge(doc['location'] || {})]
        end
      end

      # Segment is ...
      #
      # timetables - [Array]:
      #
      # Return Array
      def segment(tables)
        output = []
        tables.
          group_by {|t| t.size }. # group by departures count
          select {|size,tables| size > 0}. # drop empty tables
          each do |size,tables|
            by_first = tables.sort_by {|table| table.first }
            by_last  = tables.sort_by {|table| table.last }
            if by_first == by_last
              output.push by_first
            else
              tables.group_by{|t| t.last - t.first}.each do |diff,tables| 
                output.push tables.sort_by{|t| t.first}
              end
            end
          end
        output
      end

      # Saves
      def nodes!
        Hash[nodes.map do |id, stop|
          [id, @inserter.create_node(stop, @group_stops ? Hub : Stop)]
        end]
      end

      # Save all @@connections to the database
      # 
      # Returns ?
      def commit!

        @inserter = Neo4j::Batch::Inserter.new
        @stops = nodes!

        # Save all relationships to the database.
        @connections.each_pair do |(from, to), connection|
          # Debugging
          connection['Label'] = connection[:departures].map{|key,val| val['line'] || '?'}.uniq.join(',') 
          connection['departures'] = JSON.generate(connection.delete(:departures)) 
          connection['length'] = connection.delete(:length)
          #connection['departures'] = MessagePack.pack(connection['departures'])
          @inserter.create_rel(:connects, *@stops.values_at(from, to), connection, Graph::Connection)
        end.tap{ @inserter.shutdown }
      end

      # Merge departures from all connection to global structure
      #
      # connections - [Array]
      #
      # Returns ?
      def merge(connections)
        connections.each do |from, to, departures|
          @connections[[from.to_s,to.to_s]][:departures].merge!(departures)
        end
      end

    end
  end
end
