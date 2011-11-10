module Bagatela
  module Resources
    class Departures < Hash

      def clean?(n=nil)
        n ? count(&durations) == n : all?(&durations) 
      end

      def clean
        self.class[select(&durations)]
      end

      def clean!
        select!(&durations)
      end

      def dirty
        self.class[select(&durations(true))]
      end
      
      private

      def durations(reverse=false)
        lambda {|key,val| val.has_key?('duration')^reverse }
      end

    end
  end
end
