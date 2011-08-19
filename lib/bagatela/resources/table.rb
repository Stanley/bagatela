module Bagatela
  module Resources
    # One of many tables on the timetable, which contains departures only for
    # one specific class of days
    class Table
      include Enumerable

      # Takes one of the Timetable's *tables*
      #
      # table - [Hash]: pairs of hour and array of minutes
      def initialize(table)
        @data = []
        table.each_pair do |hour, minutes|
          minutes.each do |minute|
            @data.push(hour.to_i*60 + minute.to_i)
          end
        end
      end

      # First departure after *minutes* from midnight
      #
      # minutes - [Integer]
      #
      # Returns Integer - minutes from midnight
      def after(minutes)
        @data.find{|min| min > minutes}
      end

      # Iterates over departures
      def each &block
        @data.each &block
      end

    end
  end
end
