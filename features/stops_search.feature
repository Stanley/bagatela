Feature: Search stops
  In order to find begining/ending stops
  As a developer
  I want to use a simple yet powerful, couchdb like API

  Background:
    Given an empty database "kr"
      And design documents

  Scenario: Find stop by name
    Given the following stops:
      | _id | name             | location |
      | 1   | Dworzec Główny   | Basztowa |
      | 2   | Dworzec Towarowy |          |
      | 3   | Basztowa LOT     | Długa    |
      And build index
    When I send a GET request to http://api.bagate.la/kr/_search/Stop?q=Basztowa
    Then the response status should be 200
      And the response without rows' value._rev should be:
      """
      {"total_rows":2, "rows":[
        {"id":"1","value": {"_id": "1", "name": "Dworzec Główny", "location": "Basztowa", "type": "Stop"}},
        {"id":"3","value": {"_id": "3", "name": "Basztowa LOT", "location": "Długa", "type": "Stop"}}
      ]}
      """

    When I send a GET request to http://api.bagate.la/kr/_search/Stop?q=Basztowa%20Długa
    Then the response status should be 200
      And the response without rows' value._rev should be:
      """
      {"total_rows":1, "rows":[
        {"id":"3","value": {"_id": "3", "name": "Basztowa LOT", "location": "Długa", "type": "Stop"}}
      ]}
      """

    When I send a GET request to http://api.bagate.la/kr/_search/Stop?q=name:Dworzec
    Then the response status should be 200
      And the response without rows' value._rev should be:
      """
      {"total_rows":2, "rows":[
        {"id":"1","value": {"_id": "1", "name": "Dworzec Główny", "location": "Basztowa", "type": "Stop"}},
        {"id":"2","value": {"_id": "2", "name": "Dworzec Towarowy", "location": "", "type": "Stop"}}
      ]}
      """

  Scenario: Find stops within a given radius
    Given the following stops:
      | _id | name           | location     | lat       | lng       |
      | 1   | Dworzec Główny | Basztowa     | 50.064708 | 19.944381 |
      | 2   | Dworzec Główny | Lubicz       | 50.064662 | 19.945671 |
      | 3   | Dworzec Główny | Westerplatte | 50.064123 | 19.945086 |
      | 4   | Basztowa LOT   | Długa        | 50.066495 | 19.938925 |
      | 5   | Basztowa LOT   | Basztowa     | 50.066163 | 19.938675 |
      And build index
    When I send a GET request to http://api.bagate.la/kr/_search/Stop?q=50.064622%2019.944917&r=0.5
    Then the response status should be 200
      And the response without rows' value._rev should be:
      """
      {"total_rows":3, "rows":[
        {"id":"1","value": {"_id": "1", "name": "Dworzec Główny", "location": "Basztowa", "lat": "50.064708", "lng": "19.944381", "type": "Stop"}},
        {"id":"2","value": {"_id": "2", "name": "Dworzec Główny", "location": "Lubicz", "lat": "50.064662", "lng": "19.945671", "type": "Stop"}},
        {"id":"3","value": {"_id": "3", "name": "Dworzec Główny", "location": "Westerplatte", "lat": "50.064123", "lng": "19.945086", "type": "Stop"}}
      ]}
      """

    When I send a GET request to http://api.bagate.la/kr/_search/Stop?q=50.064622%2019.944917%20location:Basztowa&r=5
    Then the response status should be 200
      And the response without rows' value._rev should be:
      """
      {"total_rows":2, "rows":[
        {"id":"1","value": {"_id": "1", "name": "Dworzec Główny", "location": "Basztowa", "lat": "50.064708", "lng": "19.944381", "type": "Stop"}},
        {"id":"5","value": {"_id": "5", "name": "Basztowa LOT", "location": "Basztowa", "lat": "50.066163", "lng": "19.938675", "type": "Stop"}}
      ]}
      """
