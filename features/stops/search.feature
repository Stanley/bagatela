Feature: Search for stops
  In order to find out where to go
  As a developer
  I want to find stops using a simple yet powerful API

  Background:
    Given an empty database "foo"
      And design documents
      And elasticsearch index

  Scenario: Find stop by name
    Given the following stop documents:
      | _id | name             | address  |
      | 1   | Dworzec Główny   | Basztowa |
      | 2   | Dworzec Towarowy |          |
      | 3   | Basztowa LOT     | Długa    |
      And an indexed database
    When I send a GET request to http://api.bagate.la/foo/_search/Stop?q=Basztowa
    Then the response status should be 200
      And the result should be stops: 3, 1

    When I send a GET request to http://api.bagate.la/foo/_search/Stop?q=name:Dworzec
    Then the response status should be 200
      And the result should be stops: 1, 2

    When I send a GET request to http://api.bagate.la/foo/_search/Stop?q=dł*
    Then the response status should be 200
      And the result should be stop: 3

    # Won't work until #1009 issue is resolved
    When I send a GET request to http://api.bagate.la/foo/_search/Stop?q=Basztowa,Długa
    Then the response status should be 200
      And the result should be stop: 3

  Scenario: Find stops within a given radius
    Given the following stop documents:
      | _id | name           | address      | location                               |
      | 1   | Dworzec Główny | Basztowa     | { "lat": 50.064708, "lon": 19.944381 } |
      | 2   | Dworzec Główny | Lubicz       | { "lat": 50.064662, "lon": 19.945671 } |
      | 3   | Dworzec Główny | Westerplatte | { "lat": 50.064123, "lon": 19.945086 } |
      | 4   | Basztowa LOT   | Długa        | { "lat": 50.066495, "lon": 19.938925 } |
      | 5   | Basztowa LOT   | Basztowa     | { "lat": 50.066163, "lon": 19.938675 } |
      And an indexed database
    When I send a GET request to http://api.bagate.la/foo/_search/Stop:
      """
      {
        "query": {
          "filtered": {
            "query" : {
              "match_all": {}
            },
            "filter" : {
              "geo_distance" : {
                "distance" : "0.1km",
                "location" : {
                  "lat" : 50.0646,
                  "lon" : 19.9451
                }
              }
            }
          }
        }
      }
      """
    Then the response status should be 200
      And the result should be stops: 1, 2, 3

    When I send a GET request to http://api.bagate.la/foo/_search/Stop:
    """
    {
      "query": {
        "filtered" : {
          "query" : {
            "field" : { "address" : "Basztowa" }
          },
          "filter" : {
            "geo_distance" : {
              "distance" : "1km",
              "location" : {
                "lat" : 50.0646,
                "lon" : 19.9451
              }
            }
          }
        }
      }
    }
    """
    Then the response status should be 200
      And the result should be stops: 1, 5
