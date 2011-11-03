require 'forwardable'

module Bagatela
  module Resources
    # One of many tables on the timetable, which contains duration only for
    # one specific class of days
    class Table
      include Enumerable
      extend Forwardable

      def_delegators :@data, :each, :size, :empty?, :reverse, :find, :delete, :map, :to_a, :include?

      # Takes one of the Timetable's *tables*
      #
      # table - [Hash]: pairs of hour and array of minutes
      def initialize(table)
        if table.is_a?(Array) 
          @data = table
          return
        else
          @data = []
        end

        table.each_pair do |hour, minutes|
          minutes.each do |minute|
            @data.push(hour.to_i*60 + minute.to_i)
          end
        end
      end

      #
      # following - [Table]:
      #
      # Returns Hash, Array or nil
      def departures(a=nil,force=false)
        
        departures = Departures.new
        r = runs(a)
        #r.values.compact
        max = r.values.compact.max

        r.values.compact.sort.each_cons(2) do |a,b|
          if b-a > 1
            max = a
            break
          end
        end

        r.each_pair do |departure, duration|
          run = departures[departure] = {}
          if !force and (duration.nil? or duration > max)
            # TODO replace with number
            run['prediction'] = max || 1 #true 
          else
            run['duration'] = duration
          end
        end

        # Assume false connection if we couldn't match any pair.
        return if !a.nil? and departures.all? {|key,val| val.has_key?('prediction')}

        departures
      end

      # Returns Array
      def forked_departures(a,b)
        [a,b].map do |table|
          d = departures(table)
          return if d.nil?
          d.clean 
        end
        #all = departures(a+b)
        #x = departures(a).clean
        #y = departures(b).clean
        #p all, x, y
        #[a,b].map do |table|
          #Departures[ all.select {|key,val| table.include? key+val['duration']} ]
        #end
      end
        
      # Standard deviation
      #
      # following - [Table]: 
      #
      # Returns Array: Float, Float, Array
      #def standard_deviation(following)

        #runs = departures(following) or return

        #duration = runs.select do |key,val| 
          #val['duration']
        #end.map do |key, val| 
          #val['duration'] 
        #end 
        #return if duration.empty?

        #mean = duration.reduce(:+) / duration.size.to_f
        #variance = duration.inject(0){|variance, x| variance + (x-mean)**2 }
        #[Math.sqrt(duration.size > 1 ? variance/(duration.size-1) : 0), mean, runs]
      #end

      def first
        data = @data.sort
        shift = (data.size-1).downto(0).max_by do |i| 
          diff = data[i]-data[i-1] 
          i==0 ? (24*60+diff) : diff
        end
        shift == 0 ? data.first : -24*60+data[shift]
      end

      def last
        f = first
        f += 24*60 if f < 0
        @data[@data.index(f) -1]
      end

      def +(table)
        self.class.new(to_a + table.to_a)
      end

      def -(departures)
        self.class.new(to_a - departures.map{|key,val| key+val['duration']})
      end

      private 

      # Returns Hash. Pairs of departure time & trip duration.
      def runs(table)

        departures = Hash[map{|x|[x]}]
        return departures unless table

        # Special case: both tables are identical. This is the only case where
        # run duration is zero.
        return Hash[map{|x|[x,0]}] if to_a == table.to_a

        enum = merge(table).to_enum
        loop do
          x, y = enum.next, enum.peek
          if include?(x) and !include?(y)
            #departures[x]['duration'] = y-x
            departures[x] = y>x ? y-x : 24*60-x+y
            enum.next
          end
        end rescue StopIteration

        departures
      end

      # Returns Array or nil
      def merge(table)
        sum = (@data + table.to_a).sort
        sum.rotate(sum.size.times.max_by do |i|
          diff = sum[i]-sum[i-1] 
          i==0 ? (24*60+diff) : diff
        end)
      end

    end
  end
end
