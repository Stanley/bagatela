Feature: List stops
  In order to provide users with detailed information about their journey
  As a developer
  I want to build applications which know exactly where each stop is

  Background:
    Given an empty database "kr"
      And design documents

  Scenario: Find stop by name
    Given the following stops:
      | _id | name     | address      |
      | 1   | Bagatela | Dunajewskiego |
      | 2   | Bagatela | Karmelicka    |
      | 3   | Bagatela | Podwale       |
    When I send a GET request to http://api.bagate.la/kr/_design/Stops/_view/by_name?key=["Bagatela","Karmelicka"]
    Then the response status should be 200
      And the response without rows' value._rev should be:
      """
      {"total_rows":3,"offset":1,"rows":[
        {"id":"2","key":["Bagatela","Karmelicka"],"value": {"_id": "2", "name": "Bagatela", "address": "Karmelicka", "type": "Stop"}}
      ]}
      """

  @by_name

  Scenario: Find stops by name
    Given the following stops:
      | _id | name     | address      |
      | 1   | Bagatela | Dunajewskiego |
      | 2   | Bagatela | Karmelicka    |
      | 3   | Bagatela | Podwale       |
    When I send a GET request to http://api.bagate.la/kr/_design/Stops/_view/by_name?startkey=["Bagatela"]&endkey=["Bagatela",{}]
    Then the response status should be 200
      And the response without rows' value._rev should be:
      """
      {"total_rows":3, "offset":0, "rows":[
        {"id":"1", "key":["Bagatela", "Dunajewskiego"], "value": {"_id": "1", "name": "Bagatela", "address": "Dunajewskiego", "type": "Stop"}},
        {"id":"2", "key":["Bagatela", "Karmelicka"], "value": {"_id": "2", "name": "Bagatela", "address": "Karmelicka", "type": "Stop"}},
        {"id":"3", "key":["Bagatela", "Podwale"], "value": {"_id": "3", "name": "Bagatela", "address": "Podwale", "type": "Stop"}}
      ]}
      """

  Scenario: Attempt to find stops which do not exist
    When I send a GET request to http://api.bagate.la/kr/_design/Stops/_view/by_name?startkey=["Utopia"]&endkey=["Utopia",{}]
    Then the response status should be 200
      And the response should be:
      """
      {"total_rows":0, "offset":0, "rows":[]}
      """

  @by_line

  Scenario: Find stops in line
    Given the following stops:
      | _id | name                    |
      | 1   | Cmentarz Rakowicki      |
      | 2   | Cmentarz Rakowicki      |
      | 3   | Rakowiecka              |
      | 4   | Uniwersytet Ekonomiczny |
      | 5   | Lubicz                  |
      | 6   | Dworzec Główny          |
      | 7   | Basztowa LOT            |
      | 8   | Teatr Bagatela          |
      | 9   | Filharmonia             |
      | 10  | Jubilat                 |
      | 11  | Komorowskiego           |
      | 12  | Flisacka                |
      | 13  | Salvator                |
    And the following timetables:
      | _id | stop                    | stop_id | line | route                                   | source |
      | 14  | Cmentarz Rakowicki      | 1       | 2    | CMENTARZ - Rakowicka, Lubicz - SALWATOR | a      |
      | 15  | Cmentarz Rakowicki      | 2       | 2    | CMENTARZ - Rakowicka, Lubicz - SALWATOR | b      |
      | 16  | Rakowiecka              | 3       | 2    | CMENTARZ - Rakowicka, Lubicz - SALWATOR | c      |
      | 17  | Uniwersytet Ekonomiczny | 4       | 2    | CMENTARZ - Rakowicka, Lubicz - SALWATOR | d      |
      | 18  | Lubicz                  | 5       | 2    | CMENTARZ - Rakowicka, Lubicz - SALWATOR | e      |
      | 19  | Dworzec Główny          | 6       | 2    | CMENTARZ - Rakowicka, Lubicz - SALWATOR | f      |
      | 20  | Basztowa LOT            | 7       | 2    | CMENTARZ - Rakowicka, Lubicz - SALWATOR | g      |
      | 21  | Teatr Bagatela          | 8       | 2    | CMENTARZ - Rakowicka, Lubicz - SALWATOR | h      |
      | 22  | Filharmonia             | 9       | 2    | CMENTARZ - Rakowicka, Lubicz - SALWATOR | i      |
      | 23  | Jubilat                 | 10      | 2    | CMENTARZ - Rakowicka, Lubicz - SALWATOR | j      |
      | 24  | Komorowskiego           | 11      | 2    | CMENTARZ - Rakowicka, Lubicz - SALWATOR | k      |
      | 25  | Flisacka                | 12      | 2    | CMENTARZ - Rakowicka, Lubicz - SALWATOR | l      |
    When I send a GET request to http://api.bagate.la/kr/_design/Stops/_view/by_line?startkey=["2", "SALWATOR"]&endkey=["2", "SALWATOR", {}]&include_docs=true
    Then the response status should be 200
      And the response without rows' doc._rev should be:
      """
      {"total_rows":12, "offset":0, "rows":[
        {"id":"14","key":["2","SALWATOR","a"],"value":{"_id":"1"},"doc":{"_id":"1","name":"Cmentarz Rakowicki","type":"Stop"}},
        {"id":"15","key":["2","SALWATOR","b"],"value":{"_id":"2"},"doc":{"_id":"2","name":"Cmentarz Rakowicki","type":"Stop"}},
        {"id":"16","key":["2","SALWATOR","c"],"value":{"_id":"3"},"doc":{"_id":"3","name":"Rakowiecka","type":"Stop"}},
        {"id":"17","key":["2","SALWATOR","d"],"value":{"_id":"4"},"doc":{"_id":"4","name":"Uniwersytet Ekonomiczny","type":"Stop"}},
        {"id":"18","key":["2","SALWATOR","e"],"value":{"_id":"5"},"doc":{"_id":"5","name":"Lubicz","type":"Stop"}},
        {"id":"19","key":["2","SALWATOR","f"],"value":{"_id":"6"},"doc":{"_id":"6","name":"Dworzec Główny","type":"Stop"}},
        {"id":"20","key":["2","SALWATOR","g"],"value":{"_id":"7"},"doc":{"_id":"7","name":"Basztowa LOT","type":"Stop"}},
        {"id":"21","key":["2","SALWATOR","h"],"value":{"_id":"8"},"doc":{"_id":"8","name":"Teatr Bagatela","type":"Stop"}},
        {"id":"22","key":["2","SALWATOR","i"],"value":{"_id":"9"},"doc":{"_id":"9","name":"Filharmonia","type":"Stop"}},
        {"id":"23","key":["2","SALWATOR","j"],"value":{"_id":"10"},"doc":{"_id":"10","name":"Jubilat","type":"Stop"}},
        {"id":"24","key":["2","SALWATOR","k"],"value":{"_id":"11"},"doc":{"_id":"11","name":"Komorowskiego","type":"Stop"}},
        {"id":"25","key":["2","SALWATOR","l"],"value":{"_id":"12"},"doc":{"_id":"12","name":"Flisacka","type":"Stop"}}
      ]}
      """

  @polylines

  Scenario: Find line's route polyline
    Given the following stops:
      | _id | name     | polylines               |
      | 1   | Pierwszy | { "2": [[0,0], [1,1]] } |
      | 2   | Środkowy | { "3": [[1,1], [2,2]] } |
    And the following timetables:
      | line | stop_id | destination |
      | L    | 1       | OSTATNI     |
      | L    | 2       | OSTATNI     |
      | L    | 3       | OSTATNI     |
    When I send a GET request to http://api.bagate.la/kr/_design/Stops/_list/polyline/by_line?startkey=["L", "OSTATNI"]&endkey=["L", "OSTATNI", {}]&include_docs=true
    Then the response status should be 200
      And the response should be:
      """
      {"total_rows": 2, "rows": [
        {"id": "1:2", "value": {"type": "Polyline", "points": [[0,0], [1,1]]}},
        {"id": "2:3", "value": {"type": "Polyline", "points": [[1,1], [2,2]]}}
      ]}
      """

  @filter

  Scenario: Attributes filtering
    Given the following stops:
      | _id | name     | lat         | lng         | address       |
      | 1   | Bagatela | 50.06380081 | 19.93320084 | Dunajewskiego |
      | 2   | Bagatela | 50.0637207  | 19.93255997 | Karmelicka    |
      | 3   | Bagatela | 50.06309891 | 19.9326992  | Podwale       |
    When I send a GET request to http://api.bagate.la/kr/_design/Stops/_list/filter/by_name?startkey=["Bagatela"]&endkey=["Bagatela",{}]&only=lat,lng
    Then the response status should be 200
      And the response should be:
      """
      {"total_rows":3,"offset":0,"rows":[
        {"id":"1","key":["Bagatela","Dunajewskiego"],"value":{"lat":"50.06380081","lng":"19.93320084"}},
        {"id":"2","key":["Bagatela","Karmelicka"],"value":{"lat":"50.0637207","lng":"19.93255997"}},
        {"id":"3","key":["Bagatela","Podwale"],"value":{"lat":"50.06309891","lng":"19.9326992"}}
      ]}
      """
    When I send a GET request to http://api.bagate.la/kr/_design/Stops/_list/filter/by_name?startkey=["Bagatela"]&endkey=["Bagatela",{}]&except=_rev,lat,lng
    Then the response status should be 200
      And the response should be:
      """
      {"total_rows":3,"offset":0,"rows":[
        {"id":"1","key":["Bagatela","Dunajewskiego"],"value":{"_id":"1","name":"Bagatela","address":"Dunajewskiego","type":"Stop"}},
        {"id":"2","key":["Bagatela","Karmelicka"],"value":{"_id":"2","name":"Bagatela","address":"Karmelicka","type":"Stop"}},
        {"id":"3","key":["Bagatela","Podwale"],"value":{"_id":"3","name":"Bagatela","address":"Podwale","type":"Stop"}}
      ]}
      """
