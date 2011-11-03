module Bagatela
  module Resources
    class SegmentsMismatch < RuntimeError; end
    class Line
      include Comparable
      include Enumerable

      def initialize(segments, destination)

        @connections = {}
        @destination = destination.upcase

        # Line is just one timetable
        if segments.size == 1 and segments[0][0].size == 1
          @last = segments[0][0][0]
          return 
        end 

        enum = segments.each_cons(3) 
      begin
        loop do
          x, y, z = enum.next

              x2 = x[0].last
          y1, y2 = y[0].first, y[0].last
              z1 = z[0].first

          # x   y
          #  \ /
          #   z
          if x2.size + y2.size == z1.size and (x2+y2).departures(z1,true).clean?
            #@connections += [[x2,z1],[y2,z1]].map{|a,b|[a,b,a.departures(b)]}
            p "i"

            xz = x2.departures(z1)
            yz = y2.departures(z1)
            next if xz.nil? or yz.nil?

            @connections[[x2,z1]] = xz
            @connections[[y2,z1]] = yz
            enum.next

          #   x
          #  / \
          # y   z
          elsif y1.size + z1.size == x2.size # TODO not tested?
            xy, xz = x2.forked_departures(y1,z1) || next
            p "#{x2} - #{y1} & #{z1}", xy, xz
            if xy.clean? and xz.clean?
            p "ii"
              @connections[[x2,y1]] = xy
              @connections[[x2,z1]] = xz
              #enum.next
            end

          # x
          # |\
          # | y1..y2
          # |/
          # z
          elsif x2.size == z1.size and x2.size > y1.size
            p "? iii"
            xy = x2.departures(y1) or next
            xy = xy.clean
            p xy
            yz = y2.departures(z1) 
            next unless yz and yz.clean?
            p yz
            xz = x2.departures(z1-yz) or next
            xz = xz.clean
            p xz
            p z1.size

            if xy.size + xz.size == z1.size
            p "iii"
              @connections[[x2,y1]] = xy
              @connections[[x2,z1]] = xz
              @connections[[y2,z1]] = yz
              enum.next
            end
          end
        end 
      rescue StopIteration; end

        exclude = @connections.keys.map{|x,y| x}.uniq
        segments.each_cons(2) do |(a_seg,a_con),(b_seg,b_con)|
          x = a_seg.last
          y = b_seg.first

          # Don't consider nodes joined earlier
          if !exclude.include?(x) #!([x,y] & exclude).empty?
              p "connection #{x} - #{y}"

            lengths = a_con.map {|departures| departures.map{|key,val| val['duration']}.compact.max}
            gap, max = lengths.inject([0,false]) do |(max,uniq),x|
              if max == x
                uniq = false
              elsif max < x
                max = x
                uniq = true
              end
              [max, uniq]
            end unless lengths.size < 2 

            if max and i = lengths.index(gap) and 
               merge!(a_seg[i..i+1], [b_seg.first,b_seg.last])

              p "weakest: #{a_seg[i]} ~ #{a_seg[i+1]}"

              a_seg.slice!(0,i+1).reverse.each do |a|
                b_seg.unshift a
              end

              a_seg.slice!(0..-1).each do |a|
                b_seg.push a
              end

            # x -- y
            elsif not @connections.include?([x,y])
              @connections[[x,y]] = x.departures(y) or raise SegmentsMismatch 
            end
          end
        end

        segments.each do |segment, connections|
          segment.each_cons(2).zip(connections).each do |(x,y),departures|
            departures ||= x.departures(y) # TODO what?
            @connections[[x,y]] = departures #or raise SegmentsMismatch 
          end
        end

        #puts "Linia: " + @connections.map{|a,b| "#{a} - #{b}"}.join(", ") + " (#{score})"
        puts "#{score} [#{segments.map{|s| s[0][0]}.join(";")}]:\n" # + map {|from,to| "#{from}-#{to}"}.join(", ")
      end

      def each(&block)
        @connections.map{|connection| connection.flatten }.each &block
        endings.each do |last|
          yield last, @destination, last.departures
        end
      end

      # Connection(s) to terminus
      def endings
        return [@last] unless @last.nil?
        return [] if @connections.empty?
        outgoing, incoming = @connections.keys.transpose
        incoming.uniq - outgoing
      end

      def <=>(line)
        score <=> line.score
      end

      # How many runs do not reach end?
      # How much time difference there is between first and last nodes?
      # The smaller the better.
      def score
        lost = endings.inject(0){|sum,table| sum-table.size}
        time = 0
        each do |a,b,departures|
          #begin
          lost += departures.count {|dep,val| val.has_key?('prediction')}
          time += departures.reduce(0) do |sum,(dep,val)|
            sum + (val['duration'] || val['prediction']*2)
            #val.has_key?('duration') ? sum+val['duration'] : sum
          end
        #rescue
          #raise departures.inspect
        #end
        end
        #[time, lost]
        [lost, time]
      end

      def merge!(a,b)
        a1, a2 = a
        b1, b2 = b
        b2a2 = b2.departures(a2) or return

        # x1 - ... - y1 ... - yn - ... - xn
        if a1.size <= b1.size # TODO specs ==
          a1b1 = a1.departures(b1) or return

          # All a1's departures must arrive at b.first
          if a1b1.clean? and b2a2.clean?(a1.size)
            @connections[[a1,b1]] = a1b1
            @connections[[b2,a2]] = b2a2
            return true
          end
          
        # x1 - ... - xm - xm+1 - ... - xn
        #              \ /
        #               y
        else
          a1a2, a1b1 = a1.forked_departures(a2,b1) || return

          if a1b1.size > 0 and a1a2.size + a1b1.size == a1.size
            @connections[[a1,b1]] = a1b1
            @connections[[b2,a2]] = b2a2
            @connections[[a1,a2]] = a1a2
            return true
          end
        end

        nil

      end

    end
  end
end
