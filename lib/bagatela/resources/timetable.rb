require 'forwardable'

module Bagatela
  module Resources
    class Timetable < Resource
      extend Forwardable

      attr_writer :cache
      def_delegators :@cache, :empty?, :first, :last, :size, :forked_departures, :to_a, :+, :-, :include?

      def self.to_s
        "Timetables"
      end

      # If `destination` field is not defined, extract it from `route` filed.
      #
      # Returns String; timetable's line destination.
      def destination
        return self['destination'].upcase if self['destination']
        self['route'] ? self['route'].split('-').last.strip.upcase : ''
      end

      # Based on two timetables, where one follows another, we can guess (with
      # very high probability) when each ride will arrive at the next station.
      #
      # date           - [Time]: day to specify which table to use.
      # next_timetable - [Timetable]: next timetable in line.  If `nil` (next
      #                  stop is terminus) trip duration will be guessed.
      #
      # Returns Hash, where the key is time - minutes from 00:00 (eg. for 12:00
      # it would be 720) and the value is a hash with: *line* and ride's
      # *duration* time values.
      #def rides(date, following=nil)
        #table(date).rides(following)
      #end

      # Unique stop id. That is *stop_id* (if defined) or upcased *stop* - the name.
      # 
      # Returns String.
      def stop_id
        self['stop_id'] || self['stop'].upcase
      end

      # Find one of many tables.
      #
      # date - [Time]: day during which returned table must be relevant.
      #
      # Returns Table.
      def table(date)
        return @cache unless @cache.nil?

        # Iterate over each days class
        self['tables'].map do |description, table|
          [Chronik::Label.new(description), table]
        end.each do |label, table|
          return Table.new(table) if label.holidays.include?(date)
        end.each do |label, table|
          return Table.new(table) if label.weekdays.include?(date.wday)
        end
        # There is no table for given day
        Table.new({})
      end

      def departures(to=nil, date=Time.now)
        #departures = table(date).departures(to.nil?? nil : to.table(date)) or return
        d = @cache.departures(to) or return
        d.each_pair do |key,val|
          val['line'] = self['line']
        end
      end

      def to_s
        stop_id
      end

    end
  end
end
