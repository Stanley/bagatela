module Bagatela
  module Resources
    class SegmentsMismatch < RuntimeError; end
    class Line
      include Comparable
      include Enumerable

      def initialize(segments, destination=nil)

        @segments = [] #segments
        # Remember connections between segments
        @connections = {}
        @destination = destination #.upcase

        # When line is just one timetable (probably in tests only)
        if segments.size == 1 and segments[0][0].size == 1
          @last = segments[0][0][0]
          return 
        end 

        # Connect 3-piece layouts when appropriate
        triple(segments.each_cons(3))
        # Connect remaining, not connected, segments
        double(segments[0..-2].each_cons(2))

        # Connections within segments
        segments.each do |segment, connections|
          add_segment(segment, connections)
        end

        #puts "Linia: " + @connections.map{|a,b| "#{a} - #{b}"}.join(", ") + " (#{score})"
        #puts "#{score} [#{@segments.map{|s| s[0][0]}.join(";")}]:\n" # + map {|from,to| "#{from}-#{to}"}.join(", ")
      end

      def each(&block)

        # Connections between segments
        @connections.map{|connection| connection.flatten }.each &block

        # Connection(s) to terminus
        endings.each do |last|
          yield last, @destination.upcase, last.departures
        end unless @destination.nil?
      end

      def <=>(line)
        score <=> line.score
      end

      # How many runs do not reach end?
      # How much time difference there is between first and last nodes?
      # The smaller the better.
      def score

        p "~"
        x = []
        y = []

        lost = 0
        gained = beginnings.inject(0){|sum,x| sum+x.size} #or raise "errrr"

        time = 0
        group_by{|a,b,departures| b}.each do |b,arrivals|

          # Runs present in `b` but not in `a`
          gain = 0

          arrivals.each do |a,b,departures|

            gain += a.size
            dirty = departures.dirty
            l = dirty.size
            lost += l

            time += departures.reduce(0) do |sum,(dep,val)|
              sum + (val['duration'] || val['prediction']*2)
            end

            next if b.is_a?(String)

            # Co dzieje się z pozostałymi kursami?
            resumed = 0

            if secondary_departures = Table.new(dirty.keys).departures(b)
              # Kursy, które (prawdopodobnie) są wznowieniami.
              arrivals1 = secondary_departures.clean.inject([]){|arr,dep| arr.push dep[0]+dep[1]['duration']}
              arrivals2 = departures.clean.inject([]){|arr,dep| arr.push dep[0]+dep[1]['duration']}
              p [arrivals1, arrivals2]
              resumed = (arrivals1 - arrivals2).size # TODO specs
              # Odjeżdzają z tego samego przystanku z opóźnieniem; anuluj punkty karne za końcowy kurs.
              lost -= resumed
            end

            # Kursy, które nie zaczynają się na przystanku `b`, ale zostały błędnie zinterpretowane.
            #new = l-resumed-departures.clean.size
            new = l-resumed
            puts "lost=#{l}; resumed=#{resumed}; new=#{new}. (#{a} > #{b})" 
            #gain -= new > 0 ? new : 0 

            x.push("#{a} #{b}: #{departures.count {|dep,val| val.has_key?('prediction')}}") if departures.count {|dep,val| val.has_key?('prediction')} > 0
          end

            next if b.is_a?(String)
          gain = b.size - gain
          #p "gain=#{gain}"
          y.push("{a} #{b}: #{gain}") if gain > 0
          gained += gain > 0 ? gain : 0
        end
        [lost+gained, time]
      end

      #
      #
      # segment - [Array]
      #           [String]
      #
      # Returns self
      def +(segment, connections=nil)
        if !connections.nil?
          #add_segment(segment.map{|x| Resources::Timetable[x]})
          add_segment(segment, connections)
          #p @segments.size
          if @segments.size > 2
            triple([@segments[-3..-1]].to_enum) 
            double([@segments[-3..-2]].to_enum)
          end
        else
          @destination = segment
          double([@segments[-2..-1]].to_enum)
        end
        self
      end

      def to_s
        #@connections.map{|a,b| "#{a} - #{b}"}.join(", ") + " (#{score})"
        "#{score rescue "??"} [#{@segments.map{|s| s[0][0]}.join(";")}]:\n"
      end

      private

      def add_segment(segment, connections)
        segment.each_cons(2).zip(connections).each do |(x,y),departures|
          #departures ||= x.departures(y) # TODO what?
          @connections[[x,y]] = departures or raise SegmentsMismatch 
          #yield x, y, departures
        end
        raise "stop" if @segments.include?([segment, connections])
        @segments.push([segment, connections])
      end

      # One-to-one connections
      #
      # enum - [Enumerable]:
      #
      #
      def double(enum)
        exclude_x, exclude_y = @connections.empty?? [[],[]] : @connections.keys.transpose
        enum.each do |(a_seg,a_con),(b_seg,b_con)|
          x = a_seg.last
          y = b_seg.first or next

          # Don't consider nodes joined earlier
          if !exclude_x.include?(x) and !exclude_y.include?(y) #!([x,y] & exclude).empty?

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

            # Merge y into x
            if max and i = lengths.index(gap) and 
               merge!(a_seg[i..i+1], [b_seg.first,b_seg.last])

              p "weakest: #{a_seg[i]} ~ #{a_seg[i+1]}"

              a_seg.slice!(0,i+1).reverse.each do |a|
                b_con.unshift a.departures(b_seg.first)
                b_seg.unshift a
              end

              a_seg.slice!(0..-1).each do |a|
                b_con.push b_seg.last.departures(a)
                b_seg.push a
              end

            # x -- y
            elsif not @connections.include?([x,y])
              @connections[[x,y]] = x.departures(y) or raise SegmentsMismatch 
            end
          end
        end
      end

      #
      #
      # enum - [Enumerable]
      #
      #
      def triple(enum)
        begin
          loop do
            x, y, z = enum.next

                x2 = x[0].last
            y1, y2 = y[0].first, y[0].last
                z1 = z[0].first

            # x   y
            #  \ /
            #   z
            if x2.size + y2.size == z1.size and
               (x2+y2).departures(z1,true).clean?

              puts "\\/"

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
              unless (xy, xz = x2.forked_departures(y1,z1)).compact.empty?
                puts "/\\"
                @connections[[x2,y1]] = xy or raise [xy,xz].inspect
                @connections[[x2,z1]] = xz or raise [xy,xz].inspect
              end

            # x
            # |\
            # | y1..y2
            # |/
            # z
            elsif x2.size == z1.size and x2.size > y1.size
              xy = x2.departures(y1) or next
              xy.clean!
              yz = y2.departures(z1) 
              next unless yz and yz.clean?
              xz = x2.departures(z1-yz) or next
              xz.clean!

              if xy.size + xz.size == z1.size
                puts "|>"
                @connections[[x2,y1]] = xy
                @connections[[x2,z1]] = xz
                @connections[[y2,z1]] = yz
                enum.next
              end
            end
          end 
        rescue StopIteration; end
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
            @connections.delete([a1,a2])
            return true
          end
          
        # x1 - ... - xn - xn+1 - ... - xm
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

      # Connection(s) to terminus
      def endings
        return [@last] unless @last.nil?
        return [] if @connections.empty?
        outgoing, incoming = @connections.keys.transpose
 
        # TODO WHY compact?
        incoming.uniq.compact - outgoing
      end

      def beginnings
        #return [] if @connections.empty?
        outgoing = @segments.map{|s| s.first[0]}
        incoming = @connections.keys.map{|a,b| b}
 
        # TODO WHY compact?
        outgoing.uniq.compact - incoming
      end

    end
  end
end
