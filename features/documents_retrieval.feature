Feature: Documents retrieval
  In order to 
  As a developer
  I want to

  Background:
    Given an empty database "kr"

  Scenario: Attempt to get a document which does not exist
    When I send a GET request to http://api.bagate.la/kr/1
    Then the response status should be 404

  Scenario: Find timetable by id
    Given the following timetables:
      | _id | valid_since | stop     | line | table                             |
      | 1   | 12.10.2010  | Bagatela | 4    | {"Dzień powszedni": {"12": ["0","30"]}} |
    When I send a GET request to http://api.bagate.la/kr/1
    Then the response status should be 200
      And the response without _rev should be:
      """
      {"_id": "1", "valid_since": "12.10.2010", "stop": "Bagatela", "line": "4", "table": {"Dzień powszedni": {"12": ["0", "30"]}}, "type": "Timetable"}
      """

  Scenario: Find stop by id
    Given the following stops:
     | _id | name         |
     | 1   | Basztowa LOT |
    When I send a GET request to http://api.bagate.la/kr/1
    Then the response status should be 200
      And the response without _rev should be:
      """
      {"_id": "1", "name": "Basztowa LOT", "type": "Stop"}
      """

