require 'json'
require 'restclient'

module Bagatela
  module Resources
    class Resource < Hash

      #
      #
      # view_name -
      # options - Hash of options
      #
      # Returns an array of documents.
      def self.view(db, view_name, options={})
        JSON.parse(
          RestClient.get("#{COUCHDB}/#{db}" +
            "/_design/#{self}/_view/#{view_name}" +
            '?'+ options.each_pair.map{|key,val| "#{key}=#{val}"}.join('&')
          )
        )['rows'].map do |row|
          row['value']['_key'] = row['key'] if row['key']
          self.new row['value']
        end
      end

      #
      #
      # attributes - Hash
      def initialize(attributes)
        attributes.each_pair{|key,val| self[key] = val} unless attributes.nil?
      end

    end
  end
end
