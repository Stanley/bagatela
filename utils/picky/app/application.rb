# encoding: utf-8
#
# Check the Wiki http://github.com/floere/picky/wiki for more options.
# Ask me or the google group if you have questions or specific requests.
#
class PickySearch < Application
  
  # Indexing: How text is indexed.
  # Querying: How query text is handled.
  #
  default_indexing removes_characters: /[^a-zA-Z0-9\s\/\-\"\&\.]/,
                   stopwords:          /\b(and|the|of|it|in|for)\b/,
                   splits_text_on:     /[\s\/\-\"\&\.]/
                   
  default_querying removes_characters: /[^a-zA-Z0-9\s\/\-\,\&\"\~\*\:]/, # Picky needs control chars *"~: to pass through.
                   stopwords:          /\b(and|the|of|it|in|for)\b/,
                   splits_text_on:     /[\s\/\-\,\&]+/,
                   
                   maximum_tokens: 5, # Max amount of tokens passing into a query. 5 is the default.
                   substitutes_characters_with: CharacterSubstitution::European.new # Normalizes special user input, Ä -> Ae, ñ -> n etc.
                   
  # Define an index. Use a database etc. source? http://github.com/floere/picky/wiki/Sources-Configuration#sources
  #
  stops_index = index :stops,
                      Sources::Couch.new(:name, :location, url: 'http://localhost:5984/stops'),
                      category(:name,
                               similarity: Similarity::Phonetic.new(3),   # Up to three similar title word indexed (default: No similarity).
                               partial: Partial::Substring.new(from: 1)), # Indexes substrings upwards from character 1 (default: -3),
                                                                          # You'll find "picky" even when entering just a "p".
                      category(:location,
                               partial: Partial::Substring.new(from: 1)),
  
  query_options = { :weights => { [:name, :location] => +3, [:name] => +1 } } # +/- points for ordered combinations.
  
  full_stops = Query::Full.new stops_index, query_options    # A Full query returns ids, combinations, and counts.
  live_stops = Query::Live.new stops_index, query_options    # A Live query does return all that Full returns, except ids.
  
  route %r{\A/stops/full\Z} => full_stops                    # Routing is simple: url_path_regexp => query
  route %r{\A/stops/live\Z} => live_stops                    # 
  
  # Note: You can pass a query multiple indexes and it will query in all of them.
  
end
