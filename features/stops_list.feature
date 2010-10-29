Feature: List stops
  In order to provide users with detailed information about their journey
  As a developer
  I want to build applications which know exactly where each stop is

  Background:
    Given an empty database "kr"
      And a design document "Stop"

  Scenario: Find stop by name
    Given the following stops:
      | _id | name     | location      |
      | 1   | Bagatela | Dunajewskiego |
      | 2   | Bagatela | Karmelicka    |
      | 3   | Bagatela | Podwale       |
    When I send a GET request to http://api.bagate.la/kr/_design/Stop/_view/by_name?key=["Bagatela","Karmelicka"]
    Then the response status should be 200
      And the response without rows' value._rev should be:
      """
      {"total_rows":3,"offset":1,"rows":[
        {"id":"2","key":["Bagatela","Karmelicka"],"value": {"_id": "2", "name": "Bagatela", "location": "Karmelicka", "type": "Stop"}}
      ]}
      """

  Scenario: Find stops by name
    Given the following stops:
      | _id | name     | location      |
      | 1   | Bagatela | Dunajewskiego |
      | 2   | Bagatela | Karmelicka    |
      | 3   | Bagatela | Podwale       |
    When I send a GET request to http://api.bagate.la/kr/_design/Stop/_view/by_name?startkey=["Bagatela"]&endkey=["Bagatela",{}]
    Then the response status should be 200
      And the response without rows' value._rev should be:
      """
      {"total_rows":3, "offset":0, "rows":[
        {"id":"1", "key":["Bagatela", "Dunajewskiego"], "value": {"_id": "1", "name": "Bagatela", "location": "Dunajewskiego", "type": "Stop"}},
        {"id":"2", "key":["Bagatela", "Karmelicka"], "value": {"_id": "2", "name": "Bagatela", "location": "Karmelicka", "type": "Stop"}},
        {"id":"3", "key":["Bagatela", "Podwale"], "value": {"_id": "3", "name": "Bagatela", "location": "Podwale", "type": "Stop"}}
      ]}
      """

  Scenario: Attempt to find stops which do not exist
    When I send a GET request to http://api.bagate.la/kr/_design/Stop/_view/by_name?startkey=["Utopia"]&endkey=["Utopia",{}]
    Then the response status should be 200
      And the response should be:
      """
      {"total_rows":0, "offset":0, "rows":[]}
      """

  @filter

  Scenario: Attributes filtering
    Given the following stops:
      | _id | name     | lat         | lng         | location      |
      | 1   | Bagatela | 50.06380081 | 19.93320084 | Dunajewskiego |
      | 2   | Bagatela | 50.0637207  | 19.93255997 | Karmelicka    |
      | 3   | Bagatela | 50.06309891 | 19.9326992  | Podwale       |
    When I send a GET request to http://api.bagate.la/kr/_design/Stop/_list/filter/by_name?startkey=["Bagatela"]&endkey=["Bagatela",{}]&only=lat,lng
    Then the response status should be 200
      And the response should be:
      """
      {"total_rows":3,"offset":0,"rows":[
        {"id":"1","key":["Bagatela","Dunajewskiego"],"value":{"lat":"50.06380081","lng":"19.93320084"}},
        {"id":"2","key":["Bagatela","Karmelicka"],"value":{"lat":"50.0637207","lng":"19.93255997"}},
        {"id":"3","key":["Bagatela","Podwale"],"value":{"lat":"50.06309891","lng":"19.9326992"}}
      ]}
      """
    When I send a GET request to http://api.bagate.la/kr/_design/Stop/_list/filter/by_name?startkey=["Bagatela"]&endkey=["Bagatela",{}]&except=_rev,lat,lng
    Then the response status should be 200
      And the response should be:
      """
      {"total_rows":3,"offset":0,"rows":[
        {"id":"1","key":["Bagatela","Dunajewskiego"],"value":{"_id":"1","name":"Bagatela","location":"Dunajewskiego","type":"Stop"}},
        {"id":"2","key":["Bagatela","Karmelicka"],"value":{"_id":"2","name":"Bagatela","location":"Karmelicka","type":"Stop"}},
        {"id":"3","key":["Bagatela","Podwale"],"value":{"_id":"3","name":"Bagatela","location":"Podwale","type":"Stop"}}
      ]}
      """
