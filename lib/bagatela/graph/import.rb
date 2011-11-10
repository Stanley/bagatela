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
          view(@db, :by_line, {:descending => true, :reduce => false}).
          #view(@db, :by_line, {:descending => true, :reduce => false, :startkey => '["6080"]', :endkey => '["608"]'}).
          group_by {|t| t['_key'][0]}.
          each_pair do |line_no, timetables| # each line

            timetables.
              group_by {|t| t['_key'][1]}.
              each_pair do |destination, timetables| # each destination

                puts "---#{line_no} (#{destination})---"
                @line = nil # TODO get rid of

                timetables.each {|t| t.cache = t.table(date) }
                #weak_connections = []

                segments = segment(timetables) 
                next if segments.empty?

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
                end
              end

              # debug
              segments.each do |segment,conn|
                puts segment.map{|x| x.to_s}.join(", ")
              end

              #raise "stop (#{segments.size})" if segments.size > 5

              if segments.size == 1
                @line = Resources::Line.new segments, destination
              else
                #segments.permutation(2).each do |permutation|
                  #line = Resources::Line.new permutation
                  #p segments.size, permutation.size
                  #p permutation.map{|x| x[0].map{|y| y.to_s} }
                  #raise "WAAAAt?" unless segments.include?(permutation)
                  #costamcostam(line, segments-permutation+[destination])
                #end
                indexes = segments.size.times.to_a
                indexes.permutation(2).each do |permutation|
                  line = Resources::Line.new segments.values_at(*permutation)
                  costamcostam(line, segments.values_at(*(indexes-permutation))+[destination])
                end
              end


              #lines.each do |line|
                #puts "#{line.score}: " + line.map {|from,to| from.to_s}.join(", ")
              #end

              #l= lines.compact.min

        puts "\n#{@line.score}: " + @line.map {|from,to| "#{from}-#{to}"}.join(", ")
              
              p "-=-=-=-=-=-"
              # Dodaj połączenia do struktury `connections`
              @line. 
                each do |from,to,departures|
                  #if to.nil?
                    #to = destination.upcase
                    #departures = from.departures
                  #end
                  puts "#{from} => #{to} (#{departures.size})"
                  #connections.push [from, to, departures]
              end

              merge @line.to_a

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

      def costamcostam(line, segments)
        if segments.size == 1
          # Line is almost complete

          line = Marshal.load(Marshal.dump(line)).+(segments.last)
          puts line.to_s

          @line = line if @line.nil? or is_better?(line)
        else
          # Line is missing some segments
          segments[0..-2].each do |segment, connections|
            begin
              # Create one of the possible line variants. Will raise
              # SegmentsMismatch if it's not possible.
              newline = Marshal.load(Marshal.dump(line)).+(segment, connections)
              # Allow line to continue growing unless we're sure current line's
              # beginning is invalid.
              costamcostam(newline, segments-[[segment, connections]])
            rescue Resources::SegmentsMismatch; end
          end
        end
      end

      def is_better?(line)
        begin
          (@line.score <=> line.score) == 1
        rescue
          false
        end
      end

    end
  end
end
