require 'msgpack'
require 'jruby/profiler'

module Bagatela
  module Graph
    class Import

      def self.nodes!(db, group=false, inserter=nil)
        inserter = Neo4j::Batch::Inserter.new unless context = !!inserter
        Hash[nodes(db,group).map do |id, stop|
          [id, inserter.create_node(stop, group ? Hub : Stop)]
        end].tap{ inserter.shutdown unless context }
      end

      # Create and save relationships in Neo4j databse.
      #
      # db    - [String]:
      # date  - [Time]:
      #
      # Returns Array of Graph::Connections
      def self.relationships!(db, group_stops=false, date=Time.now)

        inserter = Neo4j::Batch::Inserter.new
        stops = nodes!(db, group_stops, inserter)

        # Hash of connections
        connections = {}

        # Identification of previous stop (or hub)
        from = nil
        # Remember previous line to determine if it has changed
        prev_line = nil
        # A Timetable which is one stop ahead of current timetable.
        next_timetable = nil
        # Iterate _backwards_, that is against the line's direction;
        # from the last timetable to the first.
        
        Resources::Timetable.
          #view(db, :by_line, {:descending => true, :reduce => false}).
          view(db, :by_line, {:descending => true, :reduce => false, :startkey => '["2210"]', :endkey => '["221"]'}).
          group_by {|t| t['_key'][0]}.
          each_pair do |line, timetables| # each line
            declining = []
            timetables.
              group_by {|t| t['_key'][1]}.
              each_pair do |destination, timetables| # each destination
                puts "---#{line} (#{destination})---"
                pairs = {}
                segments = segment(timetables.map{|t| t.table(date)})
                segments.each do |a|
                  #to = nil
                  a_table = a.last
                  puts "=> #{a_table.to_s}"

                  (segments.map{|x| x.first} - [a.first]).map do |b_table|

                    p "+++ #{b_table} (#{a_table.standard_deviation(b_table)})"
                    
                    #candidates.push [a_table.standard_deviation(b_table), b_table] unless a_table.standard_deviation(b_table) > 1
                    score, avg, runs = a_table.standard_deviation(b_table)
                    #puts "#{a.last.stop_id} -> #{b.first.stop_id} : #{score}"
                    [score, avg, rand, b_table, runs] if runs

                    ## Na wszelki wypadek gdyby rozkład był pusty
                    #next unless first && last
                    ## Sprawdź czy ostatni przystanek pierwszego odcinka należy do
                    ## zbioru do drugiego odcinka. Jeżeli tak, przerwij poszukiwania.
                    ##next([0,b]) if(a.include?(b.first))

                    #score = (b_table.after(first) || next) - first + 
                            #(b_table.after(last) || next) - last

                    #raise "stop" unless score
                    
                  # Choose the best matching segment.
                  end.compact.min.tap do |score, mean, rand, table, match|
                    if score
                      #to = table
                      # [from, to, std_deviation]
                      pairs[a.last] = [table, [score, mean, rand]]
                      # sprawdź czy `a` traci kursy
                      # TODO: not the best place for this
                      unless match.all? {|key,val| val['duration']}
                        declining.push([a.last, match])
                      end
                    else
                      pairs[a.last] = [destination.upcase, []]
                    end
                  end

                  # Add line's departures to each relationship in segment.
                  # Connect segment `a` with its next destination.
                  a.each_cons(2) do |from, to|
                    #from = table
                    #to_id = to.nil?? destination.upcase : to.to_s 
                    puts "#{from} -> #{to}"

                    # Get or create relationship between *from* and *to* stops
                    connections[from.to_s] ||= {}
                    unless connection = connections[from.to_s][to.to_s] #from.rels(:connects).outgoing.to_other(to).first
                      connection = {
                        'length' => 0, # TODO
                        'departures' => {}
                      }
                      # Push newly created connection to output array.
                      connections[from.to_s][to.to_s] = connection
                    end
                    connection['departures'].merge!(from.departures(to))
                    raise("stop") if connection['departures'].empty?
                    #to = from
                  end
                end

                # TODO ...
                # sprawdź czy linia dojeżdza do pętli
                if !pairs.empty? and pairs.all?{|key,val| val[1].size > 0 }
                  # Wybierz najgorszą parę, podmień drugi element na
                  # `destination`
                  #p pairs
                  mistake = pairs.max_by{|key,val| val[1]}[0]
                  pairs[mistake] = destination.upcase
                  p "FIXED"
                else
                  p "OK"
                end
                
                # Dodaj połączenia do struktury `connections`
                pairs.
                  map {|from, (to, score)| [from, [to.is_a?(String) ? nil : to, to.to_s]] }.
                  each do |from, (to, to_str)|
                  # TODO DRY! DRY! DRY!
                    puts "#{from} -> #{to_str}"

                    # Get or create relationship between *from* and *to* stops
                    connections[from.to_s] ||= {}
                    unless connection = connections[from.to_s][to_str] #from.rels(:connects).outgoing.to_other(to).first
                      connection = {
                        'length' => 0, # TODO
                        'departures' => {}
                      }
                      # Push newly created connection to output array.
                      connections[from.to_s][to_str] = connection
                    end
                    connection['departures'].merge!(from.departures(to))
                    raise("stop") if connection['departures'].empty?
                  # END DRY TODO
                end

              end

              #p "~~~ #{declining.size}"
              (connections.keys - connections.values.map{|x| x.keys}.flatten ).each do |y|
                connections[y].each_pair do |to, connection|
                  declining.each do |z, match|
                    if connection['departures'].size == match.count{|key,val| val['duration'].nil?} 
                      

                      source_table = Resources::Table.new(match.select{|key,val| val['duration'].nil?}.keys)
                      target_table = Resources::Table.new(connection['departures'].keys)
                      next unless departures = source_table.departures(target_table)

                      p '-------------------', z.to_s, y
                      connections[z.to_s][y] = {'departures' => departures}
                      #p ({'departures' => source_table.departures(target_table)}).inspect
                      # TODO: delete_if val_duration.nil?
                      #p "#{z} -> #{y}"
                    end
                  end
                end
              end
          end

          # If any used node doesn't exist in database, create it.
          (connections.keys + connections.values.map{|x| x.keys}.flatten ).uniq.each do |x|
            if stops[x].nil?
              puts "added #{x.inspect}: #{stops[x] = inserter.create_node({'name'=>x}, Hub)}"
            end
          end

          # Save all relationships to the database.
          connections.each_pair do |from_id, to_ids|
            from = stops[from_id] 
            to_ids.each do |to_id, connection|
              connection['Label'] = connection['departures'].map{|key,val| val['line']}.uniq.join(',') # Debugging
              connection['departures'] = JSON.generate(connection['departures']) 
              #connection['departures'] = MessagePack.pack(connection['departures'])
              to = stops[to_id]
              inserter.create_rel(:connects, from, to, connection, Graph::Connection)
            end
          end.tap{ inserter.shutdown }
      end

      private

      # Create nodes in Neo4j databse.
      #
      # db -
      # group - [true or false]: 
      #
      # Returns Hash of pairs: self.id => Graph::Hub
      def self.nodes(db, group)
        Hash[group ? hubs(db) : stops(db)]
      end

      def self.stops(db)
        Resources::Stop.view(db, :by_name, :reduce=>false).map do |doc|
          id = doc['finish'] ? doc['name'].upcase : doc['_id']
          stop = doc['location'] || {}
          stop['name'] = doc['name']
          [id, stop]
        end
      end

      def self.hubs(db)
        Resources::Stop.view(db, :by_name, :group_level=>1).map do |doc|
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
      def self.segment(tables)
        segments = []; length = nil
        return [] if tables.any?{|t| t.empty? }

        tables.
          group_by {|t| [t.size, t.last-t.first]}. # group by departures count
          sort.each do |key,val|                   # sort by length so we can merge +/-1 min segments
            p key
            length == key[1]-1 ? segments[-1] += val : segments.push(val)
            length = key[1]
          end

        segments.map do |tables|
          segment = tables.sort_by {|table| table.first} # TODO table[0] ?
        end
      end

    end
  end
end
