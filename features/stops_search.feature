Feature: Search stops
  In order to find begining/ending stops
  As a developer
  I want to use a simple yet powerful API

  Background:
    Given an empty database "kr"
      And design documents

  Scenario: Find stop by name
    Given the following stops:
      | _id | name             | location |
      | 1   | Dworzec Główny   | Basztowa |
      | 2   | Dworzec Towarowy |          |
      | 3   | Basztowa LOT     | Długa    |
    When I send a GET request to http://api.bagate.la/kr/_search/Stop?q=Basztowa
    Then the response status should be 200
      And the response without _rev should be:
      """
      {}
      """

    When I send a GET request to http://api.bagate.la/kr/_search/Stop?q=Basztowa%20Długa
    Then the response status should be 200
      And the response without _rev should be:
      """
      {}
      """

    When I send a GET request to http://api.bagate.la/kr/_search/Stop?q=name:Dworzec
    Then the response status should be 200
      And the response without _rev should be:
      """
      {}
      """

  Scenario: Find stops within a given radius
    Given the following stops:
      | _id | name           | location     | lat | lng |
      | 1   | Dworzec Główny | Basztowa     |     50.064708| 19.944381     |
      | 2   | Dworzec Główny | Lubicz       |     |     |
      | 3   | Dworzec Główny | Westerplatte |     |     |
      | 4   | Basztowa LOT   | Długa        |     |     |
      | 5   | Basztowa LOT   | Basztowa     |     |     |
    When I send a GET request to http://api.bagate.la/kr/_search/Stop?q=50.064622%2019.944917&r=0.5
    Then the response status should be 200
      And the response without _rev should be:
      """
      {}
      """

    When I send a GET request to http://api.bagate.la/kr/_search/Stop?q=50.064622%2019.944917%20location:Basztowa&r=5
    Then the response status should be 200
      And the response without _rev should be:
      """
      {}
      """
