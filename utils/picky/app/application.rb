# encoding: utf-8
#
# Check the Wiki http://github.com/floere/picky/wiki for more options.
# Ask me or the google group if you have questions or specific requests.
#
class PickySearch < Application
  
  # Indexing: How text is indexed.
  # Querying: How query text is handled.
  #
  indexing removes_characters: /[^a-zA-Z0-9\s\/\-\"\&\.]/,
           stopwords:          /\b(and|the|of|it|in|for)\b/,
           splits_text_on:     /[\s\/\-\"\&\.]/
                   
  searching removes_characters: /[^a-zA-Z0-9\s\/\-\,\&\.\"\~\*\:]/, # Picky needs control chars *"~: to pass through.
            stopwords:          /\b(and|the|of|it|in|for|ul|al|os|i|ii|pl|w)\b/,
            splits_text_on:     /[\s\/\-\,\&\.]+/,
            maximum_tokens: 5 # Max amount of tokens passing into a query. 5 is the default.
                   
  # Define an index. Use a database etc. source? http://github.com/floere/picky/wiki/Sources-Configuration#sources
  #

  stops = Index::Memory.new :stops do
    source   Sources::Couch.new(:name, :location, :lat, :lng,
                                url: 'http://localhost:5984/kr/', view: '_design/Stop/_view/by_name')
    category :name, partial: Partial::Substring.new(from: 1)
    category :location, partial: Partial::Substring.new(from: 3)
    #geo_categories :lat, :lng, 1
  end

  route %r{\A/kr\Z} => Search.new(stops) do
    boost [:name] => +3, [:location] => +1
  end

  route %r{/admin} => LiveParameters.new
end
