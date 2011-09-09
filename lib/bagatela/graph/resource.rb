module Bagatela
  module Graph
    module Resource

      #
      #
      # Returns String
      def uri
        date = Neo4j::Config[:storage_path]
        resource = respond_to?(:_java_node) ? 'node' : 'relationship'
        "http://graph.bagate.la/#{date}/#{resource}/#{id}"
      end

      def to_json(*a)
        uri.to_json(*a)
      end

    end
  end
end
