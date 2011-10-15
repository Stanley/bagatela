module Bagatela
  module Resources
    # One of many tables on the timetable, which contains duration only for
    # one specific class of days
    class Table
      include Enumerable

      # Takes one of the Timetable's *tables*
      #
      # table - [Hash]: pairs of hour and array of minutes
      def initialize(table, timetable=nil)
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
        @timetable = timetable
        @data.sort!
      end

      # First departure after *minutes* from midnight
      #
      # minutes - [Integer]
      # night
      #
      # Returns Integer - minutes from midnight
      def after(minutes)
        @data.find {|min| min > minutes} || (24*60 + @data[0])
      end

      #def before(minutes)
      #end

      #def index_before(minutes)
        #count = index_after(minutes) or return(@data.size - 1)
        #count > 0 ? count - 1 : nil
      #end

      # Number of departures that went before given time
      #
      # minutes
      #
      # Returns Integer - index in the minutes array
      #def index_after(minutes)
        #return nil if @data.last < minutes
        #@data.count{|min| min < minutes}
      #end

      # Iterates over duration
      def each &block
        @data.each &block
      end

      #
      #
      # Retuns [Integer]: departure time in minutes from 00:00
      def first
        (@data+[@data.first]).
          each_cons(2).
          max_by{|x,y| x < y ? y-x : 24*60-x+y }[1]
      end

      def last
        @data[@data.index(first)-1]
      end

      def size
        @data.size
      end

      def empty?
        @data.empty?
      end

      #def avg
        #(@data.reduce{|sum,x| sum + (x > 12*60 ? -24*60+x : x)} / @data.size).abs % (12*60)
      #end

      #
      # following - [Table]:
      #
      # Returns Hash
      def departures(following=nil)

        if @data == following.to_a
          return Hash[@data.map{|x| [x,{'duration'=>0}]}]
        end

        arrivals = []
        # ...
        decrease = following.nil? || @data.size > following.size
        Hash[@data.reverse.map do |departure|
          #p [ departure, @data.size, following.size , arrivals.empty?, arrivals.last ] unless following.nil?

          if !following.nil? and
             arrival = following.after(departure) and
             (arrival < 24*60 or night? or following.night?) and
             !arrivals.include?(arrival % (24*60))

            arrivals.push arrival 
            [departure, {'duration' => arrival-departure}]
          # Assume that runs do not collide.
          elsif decrease && (arrivals.empty? || departure < arrivals.last)
            # TODO: we can do better
            [departure, {'prediction' => true}] 
          else return end
        # Add line attribute
        end.each do |key,val|
          val['line'] = line
        # Validation
        end].tap do |departures|
          if !following.nil?
            #p departures
            return unless departures.count{|x,y| y['duration']} == [@data.size,following.size].min
            f = departures[first]
            #p departures
            if f['duration'] and @data.size >= following.size
              return unless (first+f['duration']) % (24*60) == following.first
            #else
              #return if false
            end
          end
        end
      end

      # Standard deviation
      #
      # following - [Table]: 
      #
      # Returns Array: Float, Float, Array
      def standard_deviation(following)

        runs = departures(following) or return

        duration = runs.select do |key,val| 
          val['duration']
        end.map do |key, val| 
          val['duration'] 
        end 
        return if duration.empty?

        mean = duration.reduce(:+) / duration.size.to_f
        variance = duration.inject(0){|variance, x| variance + (x-mean)**2 }
        [Math.sqrt(duration.size > 1 ? variance/(duration.size-1) : 0), mean, runs]
      end

      def to_s
        @timetable.stop_id
      end

      def line
        @timetable && @timetable['line'] || '?'
      end

      def night?
        @data[0] != first
      end

    end
  end
end
