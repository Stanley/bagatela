#!/usr/bin/env node

var request = require('request')
  , fs = require('fs')
  ;

var city = process.argv[2]

request({uri:'http://krakow.jakdojade.pl/molbas/transit', method:'POST', headers: {
  'Accept':'*/*',
  'Accept-Charset':'ISO-8859-2,utf-8;q=0.7,*;q=0.3',
  'Accept-Language':'pl-PL,pl;q=0.8,en-US;q=0.6,en;q=0.4',
  'Connection':'keep-alive',
  'Content-Length':'246',
  'Content-Type':'text/x-gwt-rpc; charset=UTF-8',
  'Host':city+'.jakdojade.pl',
  'Origin':'http://krakow.jakdojade.pl',
  'Referer':'http://krakow.jakdojade.pl/',
  'X-GWT-Module-Base':'http://krakow.jakdojade.pl/molbas/',
  'X-GWT-Permutation':'A489B6773B01EC476C21D1375F26F9BD'
  }, body: '7|0|7|http://krakow.jakdojade.pl/molbas/|F92AB3F710683E04BDF8C95AD8C2871F|com.molbas.gwt.client.services.TransitServices|getStopsInArea|J|D|I|1|2|3|4|6|5|6|6|6|6|7|'+city+'|0.0|90.0|0.0|90.0|17|'},
  function(err, resp, body){
    if(err){
      console.error(err)
    } else {
      console.log(body)
    }
  }
)
