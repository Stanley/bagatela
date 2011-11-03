module Bagatela
  module Resources
    class Departures < Hash

      def clean?(n=nil)
        n ? count(&durations) == n : all?(&durations) 
      end

      def clean
        self.class[select(&durations)]
      end
      
      private

      def durations
        lambda {|key,val| val.has_key?('duration')}
      end

    end
  end
end
