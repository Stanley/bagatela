Feature: Finding connections
  In order to travel more efficiently 
  As a public transport passenger
  I want to be able to find a connection between two stops

  Background:
    Given an empty graph "2011-09-08"
      And the following nodes:
        | @id | _classname                  | name        | lat         | lon         |
        | 1   | Bagatela::Graph::Stop       | Orzeszkowej | 50.05054916 | 19.93811515 |
        | 2   | Bagatela::Graph::Stop       | Stradom     | 50.05152699 | 19.94124951 |
      And the following "connection" relationships:
        | @id | @start_node | @end_node | _classname                  | rides                                                                              |
        | 1   | 1           | 2         | Bagatela::Graph::Connection | {720 => {"line" => "A", "duration" => 2}, 755 => {"line" => "B", "duration" => 1}} |

  Scenario: Connection which starts not sooner than...
    When I send a POST request to http://graph.bagate.la/2011-09-08/node/1/connection
      """
      {
        "to": "http://graph.bagate.la/2011-09-08/node/2",
        "start_at": "12:34"
      }
      """
    Then the response status should be 200
      And the response should be:
      """
      {
        "nodes": ["http://graph.bagate.la/2011-09-08/node/1", "http://graph.bagate.la/2011-09-08/node/2"],
        "departures": {
          "12:35": {
            "line": "B",
            "duration": 1,
            "relationship": "http://graph.bagate.la/2011-09-08/relationship/1"
          }
        },
        "length": 1,
        "arrival": "2011-09-08T12:36:00Z"
      }
      """

  Scenario: Connection which ends not later than...
    When I send a POST request to http://graph.bagate.la/2011-09-08/node/1/connection
      """
      {
        "to": "http://graph.bagate.la/2011-09-08/node/2",
        "finish_at": "12:34"
      }
      """
    Then the response status should be 200
      And the response should be:
      """
      {
        "nodes": ["http://graph.bagate.la/2011-09-08/node/1", "http://graph.bagate.la/2011-09-08/node/2"],
        "departures": {
          "12:00": {
            "line": "A",
            "duration": 2,
            "relationship": "http://graph.bagate.la/2011-09-08/relationship/1"
          }
        },
        "length": 1,
        "arrival": "2011-09-08T12:02:00Z"
      }
      """

  Scenario: Connection not found
    When I send a POST request to http://graph.bagate.la/2011-09-08/node/2/connection
      """
      {
        "to": "http://graph.bagate.la/2011-09-08/node/1",
        "start_at": "12:34"
      }
      """
    Then the response status should be 404
      And the response should be:
      """
      {
        "error"  : "connection_not_found",
        "message": "No connection found using current algorithm and parameters"
      }
      """

