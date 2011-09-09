require 'unicode'

module Bagatela
  module Resources
    class Timetable < Resource

      def self.to_s
        "Timetables"
      end

      # If `destination` field is not defined, extract it from `route` filed.
      #
      # Returns String; timetable's line destination.
      def destination
        self['destination'] ? Unicode.upcase(self['destination']).force_encoding("UTF-8") :
        self['route'].split('-').last.strip.split.map{|word| Unicode.upcase(word)}.join(' ').force_encoding("UTF-8")
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
      def rides(date, next_timetable=nil)
        output = {}
        table(date).each do |departure|
          arrival = if next_timetable
            next_timetable.table(date).after(departure)
          end || departure + 1 # TODO: we can do better

          output[departure] = {'line' => self['line'],
                               'duration' => arrival-departure}
        end
        output
      end

      # Unique stop id. That is *stop_id* (if defined) or upcased *stop* - the name.
      # 
      # Returns String.
      def stop_id
        self['stop_id'] || Unicode.upcase(self['stop']).force_encoding("UTF-8")
      end

      # Find one of many tables.
      #
      # date - [Time]: day during which returned table must be relevant.
      #
      # Returns Table.
      def table(date)
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

    end
  end
end
