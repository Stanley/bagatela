Feature: List timetables
  In order to provide users with detailed information about their journey
  As a developer
  I want to build applications which know exactly when buses and trams departure

  Background:
    Given an empty database "kr"
      And a design document "Timetable"

  @by_line

  Scenario: Find timetables by line
    Given the following timetables:
      | _id | valid_since | stop                    | line | route                                                                                                                 | table | url                                                      |
      | 1   | 13.10.2010  | Cmentarz Rakowicki      | 2    | CMENTARZ RAKOWICKI - Rakowicka, Lubicz, Basztowa, Dunajewskiego, Straszewskiego, Zwierzyniecka, Kościuszki - SALWATOR | {}    | http://rozklady.mpk.krakow.pl/aktualne/0002/0002t012.htm |
      | 2   | 13.10.2010  | Cmentarz Rakowicki      | 2    | CMENTARZ RAKOWICKI - Rakowicka, Lubicz, Basztowa, Dunajewskiego, Straszewskiego, Zwierzyniecka, Kościuszki - SALWATOR | {}    | http://rozklady.mpk.krakow.pl/aktualne/0002/0002t013.htm |
      | 3   | 13.10.2010  | Rakowiecka              | 2    | CMENTARZ RAKOWICKI - Rakowicka, Lubicz, Basztowa, Dunajewskiego, Straszewskiego, Zwierzyniecka, Kościuszki - SALWATOR | {}    | http://rozklady.mpk.krakow.pl/aktualne/0002/0002t014.htm |
      | 4   | 13.10.2010  | Uniwersytet Ekonomiczny | 2    | CMENTARZ RAKOWICKI - Rakowicka, Lubicz, Basztowa, Dunajewskiego, Straszewskiego, Zwierzyniecka, Kościuszki - SALWATOR | {}    | http://rozklady.mpk.krakow.pl/aktualne/0002/0002t015.htm | 
      | 5   | 13.10.2010  | Lubicz                  | 2    | CMENTARZ RAKOWICKI - Rakowicka, Lubicz, Basztowa, Dunajewskiego, Straszewskiego, Zwierzyniecka, Kościuszki - SALWATOR | {}    | http://rozklady.mpk.krakow.pl/aktualne/0002/0002t016.htm |
      | 6   | 13.10.2010  | Dworzec Główny          | 2    | CMENTARZ RAKOWICKI - Rakowicka, Lubicz, Basztowa, Dunajewskiego, Straszewskiego, Zwierzyniecka, Kościuszki - SALWATOR | {}    | http://rozklady.mpk.krakow.pl/aktualne/0002/0002t017.htm |
      | 7   | 13.10.2010  | Basztowa LOT            | 2    | CMENTARZ RAKOWICKI - Rakowicka, Lubicz, Basztowa, Dunajewskiego, Straszewskiego, Zwierzyniecka, Kościuszki - SALWATOR | {}    | http://rozklady.mpk.krakow.pl/aktualne/0002/0002t018.htm |
      | 8   | 13.10.2010  | Teatr Bagatela          | 2    | CMENTARZ RAKOWICKI - Rakowicka, Lubicz, Basztowa, Dunajewskiego, Straszewskiego, Zwierzyniecka, Kościuszki - SALWATOR | {}    | http://rozklady.mpk.krakow.pl/aktualne/0002/0002t019.htm |
      | 9   | 13.10.2010  | Filharmonia             | 2    | CMENTARZ RAKOWICKI - Rakowicka, Lubicz, Basztowa, Dunajewskiego, Straszewskiego, Zwierzyniecka, Kościuszki - SALWATOR | {}    | http://rozklady.mpk.krakow.pl/aktualne/0002/0002t020.htm |
      | 10  | 13.10.2010  | Jubilat                 | 2    | CMENTARZ RAKOWICKI - Rakowicka, Lubicz, Basztowa, Dunajewskiego, Straszewskiego, Zwierzyniecka, Kościuszki - SALWATOR | {}    | http://rozklady.mpk.krakow.pl/aktualne/0002/0002t021.htm |
      | 11  | 13.10.2010  | Komorowskiego           | 2    | CMENTARZ RAKOWICKI - Rakowicka, Lubicz, Basztowa, Dunajewskiego, Straszewskiego, Zwierzyniecka, Kościuszki - SALWATOR | {}    | http://rozklady.mpk.krakow.pl/aktualne/0002/0002t022.htm |
      | 12  | 13.10.2010  | Flisacka                | 2    | CMENTARZ RAKOWICKI - Rakowicka, Lubicz, Basztowa, Dunajewskiego, Straszewskiego, Zwierzyniecka, Kościuszki - SALWATOR | {}    | http://rozklady.mpk.krakow.pl/aktualne/0002/0002t023.htm |
    When I send a GET request to http://api.bagate.la/kr/_design/Timetable/_view/by_line?startkey=[2,"SALWATOR"]&endkey=[2,"SALWATOR",{}]&reduce=false
    Then the response status should be 200
      And the response should be:
      """
      { "total_rows": 12, "offset": 0, "rows": [
          { "id": "1",
            "key": [ 2, "SALWATOR", 12 ],
            "value": {
              "valid_since": "13.10.2010",
              "stop": "Cmentarz Rakowicki",
              "line": "2",
              "route": "CMENTARZ RAKOWICKI - Rakowicka, Lubicz, Basztowa, Dunajewskiego, Straszewskiego, Zwierzyniecka, Kościuszki - SALWATOR",
              "table": { },
              "url": "http://rozklady.mpk.krakow.pl/aktualne/0002/0002t012.htm",
              "type": "Timetable"
            }
          },
          { "id": "2",
            "key": [ 2, "SALWATOR", 13 ],
            "value": {
              "valid_since": "13.10.2010",
              "stop": "Cmentarz Rakowicki",
              "line": "2",
              "route": "CMENTARZ RAKOWICKI - Rakowicka, Lubicz, Basztowa, Dunajewskiego, Straszewskiego, Zwierzyniecka, Kościuszki - SALWATOR",
              "table": { },
              "url": "http://rozklady.mpk.krakow.pl/aktualne/0002/0002t013.htm",
              "type": "Timetable"
            }
          },
          { "id": "3",
            "key": [ 2, "SALWATOR", 14 ],
            "value": {
              "valid_since": "13.10.2010",
              "stop": "Rakowiecka",
              "line": "2",
              "route": "CMENTARZ RAKOWICKI - Rakowicka, Lubicz, Basztowa, Dunajewskiego, Straszewskiego, Zwierzyniecka, Kościuszki - SALWATOR",
              "table": { },
              "url": "http://rozklady.mpk.krakow.pl/aktualne/0002/0002t014.htm",
              "type": "Timetable"
            }
          },
          { "id": "4",
            "key": [ 2, "SALWATOR", 15 ],
            "value": {
              "valid_since": "13.10.2010",
              "stop": "Uniwersytet Ekonomiczny",
              "line": "2",
              "route": "CMENTARZ RAKOWICKI - Rakowicka, Lubicz, Basztowa, Dunajewskiego, Straszewskiego, Zwierzyniecka, Kościuszki - SALWATOR",
              "table": { },
              "url": "http://rozklady.mpk.krakow.pl/aktualne/0002/0002t015.htm",
              "type": "Timetable"
            }
          },
          { "id": "5",
            "key": [ 2, "SALWATOR", 16 ],
            "value": {
              "valid_since": "13.10.2010",
              "stop": "Lubicz",
              "line": "2",
              "route": "CMENTARZ RAKOWICKI - Rakowicka, Lubicz, Basztowa, Dunajewskiego, Straszewskiego, Zwierzyniecka, Kościuszki - SALWATOR",
              "table": { },
              "url": "http://rozklady.mpk.krakow.pl/aktualne/0002/0002t016.htm",
              "type": "Timetable"
            }
          },
          { "id": "6",
            "key": [ 2, "SALWATOR", 17 ],
            "value": {
              "valid_since": "13.10.2010",
              "stop": "Dworzec Główny",
              "line": "2",
              "route": "CMENTARZ RAKOWICKI - Rakowicka, Lubicz, Basztowa, Dunajewskiego, Straszewskiego, Zwierzyniecka, Kościuszki - SALWATOR",
              "table": { },
              "url": "http://rozklady.mpk.krakow.pl/aktualne/0002/0002t017.htm",
              "type": "Timetable"
            }
          },
          { "id": "7",
            "key": [ 2, "SALWATOR", 18 ],
            "value": {
              "valid_since": "13.10.2010",
              "stop": "Basztowa LOT",
              "line": "2",
              "route": "CMENTARZ RAKOWICKI - Rakowicka, Lubicz, Basztowa, Dunajewskiego, Straszewskiego, Zwierzyniecka, Kościuszki - SALWATOR",
              "table": { },
              "url": "http://rozklady.mpk.krakow.pl/aktualne/0002/0002t018.htm",
              "type": "Timetable"
            }
          },
          { "id": "8",
            "key": [ 2, "SALWATOR", 19 ],
            "value": {
              "valid_since": "13.10.2010",
              "stop": "Teatr Bagatela",
              "line": "2",
              "route": "CMENTARZ RAKOWICKI - Rakowicka, Lubicz, Basztowa, Dunajewskiego, Straszewskiego, Zwierzyniecka, Kościuszki - SALWATOR",
              "table": { },
              "url": "http://rozklady.mpk.krakow.pl/aktualne/0002/0002t019.htm",
              "type": "Timetable"
            }
          },
          { "id": "9",
            "key": [ 2, "SALWATOR", 20 ],
            "value": {
              "valid_since": "13.10.2010",
              "stop": "Filharmonia",
              "line": "2",
              "route": "CMENTARZ RAKOWICKI - Rakowicka, Lubicz, Basztowa, Dunajewskiego, Straszewskiego, Zwierzyniecka, Kościuszki - SALWATOR",
              "table": { },
              "url": "http://rozklady.mpk.krakow.pl/aktualne/0002/0002t020.htm",
              "type": "Timetable"
            }
          },
          { "id": "10",
            "key": [ 2, "SALWATOR", 21 ],
            "value": {
              "valid_since": "13.10.2010",
              "stop": "Jubilat",
              "line": "2",
              "route": "CMENTARZ RAKOWICKI - Rakowicka, Lubicz, Basztowa, Dunajewskiego, Straszewskiego, Zwierzyniecka, Kościuszki - SALWATOR",
              "table": { },
              "url": "http://rozklady.mpk.krakow.pl/aktualne/0002/0002t021.htm",
              "type": "Timetable"
            }
          },
          { "id": "11",
            "key": [ 2, "SALWATOR", 22 ],
            "value": {
              "valid_since": "13.10.2010",
              "stop": "Komorowskiego",
              "line": "2",
              "route": "CMENTARZ RAKOWICKI - Rakowicka, Lubicz, Basztowa, Dunajewskiego, Straszewskiego, Zwierzyniecka, Kościuszki - SALWATOR",
              "table": { },
              "url": "http://rozklady.mpk.krakow.pl/aktualne/0002/0002t022.htm",
              "type": "Timetable"
            }
          },
          { "id": "12",
            "key": [ 2, "SALWATOR", 23 ],
            "value": {
              "valid_since": "13.10.2010",
              "stop": "Flisacka",
              "line": "2",
              "route": "CMENTARZ RAKOWICKI - Rakowicka, Lubicz, Basztowa, Dunajewskiego, Straszewskiego, Zwierzyniecka, Kościuszki - SALWATOR",
              "table": { },
              "url": "http://rozklady.mpk.krakow.pl/aktualne/0002/0002t023.htm",
              "type": "Timetable"
            }
          }
        ]
      }
      """

  @by_line

  Scenario: Lines' route(s)
    Given the following timetables:
      | stop                 | line | route                                                                                                                                      | url                                                      |
      | Prądnik Czerwony     | 105  | PRĄDNIK CZERWONY - Strzelców, Powstańców, Majora, Dobrego Pasterza, Al. 29 Listopada, Pawia - DWORZEC GŁÓWNY ZACHÓD (GALERIA)              | http://rozklady.mpk.krakow.pl/aktualne/0105/0105t001.htm |
      | Powstańców Garaże    | 105  | PRĄDNIK CZERWONY - Strzelców, Powstańców, Majora, Dobrego Pasterza, Al. 29 Listopada, Pawia - DWORZEC GŁÓWNY ZACHÓD (GALERIA)              | http://rozklady.mpk.krakow.pl/aktualne/0105/0105t002.htm |
      | Powstańców           | 105  | PRĄDNIK CZERWONY - Strzelców, Powstańców, Majora, Dobrego Pasterza, Al. 29 Listopada, Pawia - DWORZEC GŁÓWNY ZACHÓD (GALERIA)              | http://rozklady.mpk.krakow.pl/aktualne/0105/0105t003.htm |
      | Majora               | 105  | PRĄDNIK CZERWONY - Strzelców, Powstańców, Majora, Dobrego Pasterza, Al. 29 Listopada, Pawia - DWORZEC GŁÓWNY ZACHÓD (GALERIA)              | http://rozklady.mpk.krakow.pl/aktualne/0105/0105t004.htm |
      | Al. 29 Listopada     | 105  | PRĄDNIK CZERWONY - Strzelców, Powstańców, Majora, Dobrego Pasterza, Al. 29 Listopada, Pawia - DWORZEC GŁÓWNY ZACHÓD (GALERIA)              | http://rozklady.mpk.krakow.pl/aktualne/0105/0105t005.htm |
      | Opolska Estrada      | 105  | PRĄDNIK CZERWONY - Strzelców, Powstańców, Majora, Dobrego Pasterza, Al. 29 Listopada, Pawia - DWORZEC GŁÓWNY ZACHÓD (GALERIA)              | http://rozklady.mpk.krakow.pl/aktualne/0105/0105t006.htm |
      | Uniwersytet Rolniczy | 105  | PRĄDNIK CZERWONY - Strzelców, Powstańców, Majora, Dobrego Pasterza, Al. 29 Listopada, Pawia - DWORZEC GŁÓWNY ZACHÓD (GALERIA)              | http://rozklady.mpk.krakow.pl/aktualne/0105/0105t007.htm |
      | Biskupa Prandoty     | 105  | PRĄDNIK CZERWONY - Strzelców, Powstańców, Majora, Dobrego Pasterza, Al. 29 Listopada, Pawia - DWORZEC GŁÓWNY ZACHÓD (GALERIA)              | http://rozklady.mpk.krakow.pl/aktualne/0105/0105t008.htm |
      | Cmentarz             | 105  | PRĄDNIK CZERWONY - Strzelców, Powstańców, Majora, Dobrego Pasterza, Al. 29 Listopada, Pawia - DWORZEC GŁÓWNY ZACHÓD (GALERIA)              | http://rozklady.mpk.krakow.pl/aktualne/0105/0105t009.htm |
      | Politechnika         | 105  | PRĄDNIK CZERWONY - Strzelców, Powstańców, Majora, Dobrego Pasterza, Al. 29 Listopada, Pawia - DWORZEC GŁÓWNY ZACHÓD (GALERIA)              | http://rozklady.mpk.krakow.pl/aktualne/0105/0105t010.htm |
      | Cmentarz Batowice    | 105  | CMENTARZ BATOWICE - Powstańców, Strzelców, Powstańców, Majora, Dobrego Pasterza, Al. 29 Listopada, Pawia - DWORZEC GŁÓWNY ZACHÓD (GALERIA) | http://rozklady.mpk.krakow.pl/aktualne/0105/0105t022.htm |
      | Cmentarz Batowice    | 105  | CMENTARZ BATOWICE - Powstańców, Strzelców, Powstańców, Majora, Dobrego Pasterza, Al. 29 Listopada, Pawia - DWORZEC GŁÓWNY ZACHÓD (GALERIA) | http://rozklady.mpk.krakow.pl/aktualne/0105/0105t023.htm |
    When I send a GET request to http://api.bagate.la/kr/_design/Timetable/_view/by_line?group=true&group_level=2
    Then the response status should be 200
      And the response should be:
      """
      {"rows":  [
        {"key": [105, "DWORZEC GŁÓWNY ZACHÓD (GALERIA)"], "value":  [
          "PRĄDNIK CZERWONY - Strzelców, Powstańców, Majora, Dobrego Pasterza, Al. 29 Listopada, Pawia - DWORZEC GŁÓWNY ZACHÓD (GALERIA)",
          "CMENTARZ BATOWICE - Powstańców, Strzelców, Powstańców, Majora, Dobrego Pasterza, Al. 29 Listopada, Pawia - DWORZEC GŁÓWNY ZACHÓD (GALERIA)"
      ]}]}
      """

  @by_stop_id

  Scenario: Find timetables by stop id
    Given the following stops:
      | _id | name     | location   |
      | 1   | Bagatela | Karmelicka |
    And the following timetables:
      | _id | stop     | stop_id | table |
      | 2   | Bagatela | 1       | {}    |
      | 3   | Bagatela | 1       | {}    |
      | 4   | Bagatela | 1       | {}    |
    When I send a GET request to http://api.bagate.la/kr/_design/Timetable/_view/by_stop_id?startkey=["1"]&endkey=["1",{}]
    Then the response status should be 200
      And the response should be:
      """
      { "total_rows": 4, "offset": 0, "rows":  [
        { "id": "1", 
          "key": ["1", 0],
          "value": {"name": "Bagatela", "location": "Karmelicka", "type": "Stop"}},
        { "id": "2",
          "key": ["1", 1],
          "value":  {"stop": "Bagatela", "stop_id": "1", "table": {}, "type": "Timetable"}},
        { "id": "3",
          "key": ["1", 1],
          "value":  {"stop": "Bagatela", "stop_id": "1", "table": {}, "type": "Timetable"}},
        { "id": "4",
          "key": ["1", 1],
          "value":  {"stop": "Bagatela", "stop_id": "1", "table": {}, "type": "Timetable"}}
      ]}
      """

    When I send a GET request to http://api.bagate.la/kr/_design/Timetable/_view/by_stop_id?key=["1",1]
    Then the response status should be 200
      And the response should be:
      """
      { "total_rows": 4, "offset": 1, "rows":  [
        { "id": "2",
          "key": ["1", 1],
          "value":  {"stop": "Bagatela", "stop_id": "1", "table": {}, "type": "Timetable"}},
        { "id": "3",
          "key": ["1", 1],
          "value":  {"stop": "Bagatela", "stop_id": "1", "table": {}, "type": "Timetable"}},
        { "id": "4",
          "key": ["1", 1],
          "value":  {"stop": "Bagatela", "stop_id": "1", "table": {}, "type": "Timetable"}}
      ]}
      """

  @by_stop

  Scenario: Find timetables by stop name
    Given the following stops:
      | _id | name     | location      |
      | 1   | Bagatela | Dunajewskiego |
      | 2   | Bagatela | Karmelicka    |
      | 3   | Bagatela | Podwale       |
    And the following timetables:
      | _id | line | stop     | stop_id | route                                                                                                                                                                                                                                  | table |
      | 4   | 14   | Bagatela | 1       | MISTRZEJOWICE - ks. Jancarza, Srebrnych Orłów, Mikołajczyka, Broniewskiego, Andersa, Bieńczycka, Al. Pokoju, Al. Powstania Warszawskiego, Lubicz, Basztowa, Dunajewskiego, Karmelicka, Królewska, Podchorążych, Bronowicka - BRONOWICE | {}    |
      | 5   | 14   | Bagatela | 2       | BRONOWICE - Bronowicka, Podchorążych, Królewska, Karmelicka, Basztowa, Lubicz, Al. Powstania Warszawskiego, Al. Pokoju, Bieńczycka, Andersa, Broniewskiego, Mikołajczyka, Srebrnych Orłów, ks. Jancarza - MISTRZEJOWICE                | {}    |
      | 6   | 15   | Bagatela | 3       | CICHY KĄCIK - Al. 3 Maja, Podwale, Basztowa, Lubicz, Mogilska, Al. Jana Pawła II, Ptaszyckiego, Igołomska - PLESZÓW                                                                                                                    | {}    |
      | 7   | 15   | Bagatela | 1       | PLESZÓW - Igołomska, Ptaszyckiego, Al. Jana Pawła II, Mogilska, Lubicz, Basztowa, Dunajewskiego, Piłsudskiego, Al. 3 Maja - CICHY KĄCIK                                                                                                | {}    |
    When I send a GET request to http://api.bagate.la/kr/_design/Timetable/_view/by_stop?startkey=["Bagatela"]&endkey=["Bagatela",{}]
    Then the response status should be 200
      And the response should be:
      """
      { "total_rows": 4, "offset": 0, "rows": [
          { "id": "4",
            "key": [ "Bagatela", 14, "BRONOWICE" ],
            "value": {
              "line": "14",
              "stop": "Bagatela",
              "stop_id": "1",
              "route": "MISTRZEJOWICE - ks. Jancarza, Srebrnych Orłów, Mikołajczyka, Broniewskiego, Andersa, Bieńczycka, Al. Pokoju, Al. Powstania Warszawskiego, Lubicz, Basztowa, Dunajewskiego, Karmelicka, Królewska, Podchorążych, Bronowicka - BRONOWICE",
              "table": { },
              "type": "Timetable"
            }
          },
          { "id": "5",
            "key": [ "Bagatela", 14, "MISTRZEJOWICE" ],
            "value": {
              "line": "14",
              "stop": "Bagatela",
              "stop_id": "2",
              "route": "BRONOWICE - Bronowicka, Podchorążych, Królewska, Karmelicka, Basztowa, Lubicz, Al. Powstania Warszawskiego, Al. Pokoju, Bieńczycka, Andersa, Broniewskiego, Mikołajczyka, Srebrnych Orłów, ks. Jancarza - MISTRZEJOWICE",
              "table": { },
              "type": "Timetable"
            }
          },
          { "id": "7",
            "key": [ "Bagatela", 15, "CICHY KĄCIK" ],
            "value": {
              "line": "15",
              "stop": "Bagatela",
              "stop_id": "1",
              "route": "PLESZÓW - Igołomska, Ptaszyckiego, Al. Jana Pawła II, Mogilska, Lubicz, Basztowa, Dunajewskiego, Piłsudskiego, Al. 3 Maja - CICHY KĄCIK",
              "table": { },
              "type": "Timetable"
            }
          },
          { "id": "6",
            "key": [ "Bagatela", 15, "PLESZÓW" ],
            "value": {
              "line": "15",
              "stop": "Bagatela",
              "stop_id": "3",
              "route": "CICHY KĄCIK - Al. 3 Maja, Podwale, Basztowa, Lubicz, Mogilska, Al. Jana Pawła II, Ptaszyckiego, Igołomska - PLESZÓW",
              "table": { },
              "type": "Timetable"
            }
          }
        ]
      }
      """

    # Find timetables by stop name and line number
    When I send a GET request to http://api.bagate.la/kr/_design/Timetable/_view/by_stop?startkey=["Bagatela",14]&endkey=["Bagatela",14,{}]
    Then the response status should be 200
      And the response should be:
      """
      {"total_rows": 4,
       "offset": 0,
       "rows": 
        [{"id": "4",
          "key": ["Bagatela", 14, "BRONOWICE"],
          "value": 
           {"line": "14",
            "stop": "Bagatela",
            "stop_id": "1",
            "route": 
             "MISTRZEJOWICE - ks. Jancarza, Srebrnych Orłów, Mikołajczyka, Broniewskiego, Andersa, Bieńczycka, Al. Pokoju, Al. Powstania Warszawskiego, Lubicz, Basztowa, Dunajewskiego, Karmelicka, Królewska, Podchorążych, Bronowicka - BRONOWICE",
            "table": {},
            "type": "Timetable"}},
         {"id": "5",
          "key": ["Bagatela", 14, "MISTRZEJOWICE"],
          "value": 
           {"line": "14",
            "stop": "Bagatela",
            "stop_id": "2",
            "route": 
             "BRONOWICE - Bronowicka, Podchorążych, Królewska, Karmelicka, Basztowa, Lubicz, Al. Powstania Warszawskiego, Al. Pokoju, Bieńczycka, Andersa, Broniewskiego, Mikołajczyka, Srebrnych Orłów, ks. Jancarza - MISTRZEJOWICE",
            "table": {},
            "type": "Timetable"}}]}
      """
      
    # Find one timetable by stop name, line number and it's destination
    When I send a GET request to http://api.bagate.la/kr/_design/Timetable/_view/by_stop?key=["Bagatela",14,"BRONOWICE"]
    Then the response status should be 200
      And the response should be:
      """
      {"total_rows": 4,
       "offset": 0,
       "rows": 
        [{"id": "4",
          "key": ["Bagatela", 14, "BRONOWICE"],
          "value": 
           {"line": "14",
            "stop": "Bagatela",
            "stop_id": "1",
            "route": 
             "MISTRZEJOWICE - ks. Jancarza, Srebrnych Orłów, Mikołajczyka, Broniewskiego, Andersa, Bieńczycka, Al. Pokoju, Al. Powstania Warszawskiego, Lubicz, Basztowa, Dunajewskiego, Karmelicka, Królewska, Podchorążych, Bronowicka - BRONOWICE",
            "table": {},
            "type": "Timetable"}}]}
      """

  @by_uri

  Scenario: Find timetables by source
    Given the following timetables:
      | _id | source                                                   |
      | 1   | http://rozklady.mpk.krakow.pl/aktualne/0099/0099t014.htm |
      | 2   | http://rozklady.mpk.krakow.pl/aktualne/0099/0099t030.htm |
    When I send a GET request to http://api.bagate.la/kr/_design/Timetable/_view/by_uri?startkey=["rozklady.mpk.krakow.pl","0099"]&endkey=["rozklady.mpk.krakow.pl","0099",{}]
    Then the response status should be 200
      And the response should be:
      """
      {"total_rows": 2, "offset": 0, "rows":  [
        {"id": "1",
        "key": ["rozklady.mpk.krakow.pl", "0099", "0099t014.htm"],
        "value":  {"source": "http://rozklady.mpk.krakow.pl/aktualne/0099/0099t014.htm", "type": "Timetable"}},
        {"id": "2",
        "key": ["rozklady.mpk.krakow.pl", "0099", "0099t030.htm"],
        "value":  {"source": "http://rozklady.mpk.krakow.pl/aktualne/0099/0099t030.htm", "type": "Timetable"}}]}
      """

    When I send a GET request to http://api.bagate.la/kr/_design/Timetable/_view/by_uri?key=["rozklady.mpk.krakow.pl","0099","0099t014.htm"]
    Then the response status should be 200
      And the response should be:
      """
      {"total_rows": 2, "offset": 0, "rows":  [
        {"id": "1",
        "key": ["rozklady.mpk.krakow.pl", "0099", "0099t014.htm"],
        "value":  {"source": "http://rozklady.mpk.krakow.pl/aktualne/0099/0099t014.htm", "type": "Timetable"}}]}
      """

  @polylines

  Scenario: Find line's route segments

  Scenario: Find line's route polyline

  @filter

  Scenario: Attributes filtering
    Given the following timetables:
      | _id | line | route                                                                                                           | stop    | table                          | valid_since |
      | 1   | 1    | WZGÓRZA KRZESŁAWICKIE - Kocmyrzowska, Bieńczycka, Al. Pokoju, Grzegórzecka, Dietla, Starowiślna - POCZTA GŁÓWNA | Darwina | {"Soboty": {"5": ["15","35"]}} | 14.10.2010  |
    When I send a GET request to http://api.bagate.la/kr/_design/Timetable/_list/filter/by_stop?only=line,stop
    Then the response status should be 200
      And the response should be:
      """
      {"total_rows": 1, "offset": 0, "rows": [
        {"id": "1", "key": ["Darwina", 1, "POCZTA GŁÓWNA"], "value": {"stop": "Darwina", "line": "1"}}
      ]}
      """

    When I send a GET request to http://api.bagate.la/kr/_design/Timetable/_list/filter/by_stop?except=_id,_rev,route,table
    Then the response status should be 200
      And the response should be:
      """
      {"total_rows": 1, "offset": 0, "rows": [
        {"id": "1", "key": ["Darwina", 1, "POCZTA GŁÓWNA"], "value": {"line": "1", "stop": "Darwina", "valid_since": "14.10.2010", "type": "Timetable"}}
      ]}
      """
