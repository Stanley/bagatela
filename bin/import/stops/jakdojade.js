#!/usr/bin/env node

var request = require('request')
  , fs = require('fs')
  ;

var city = process.argv[2]

request({uri:'http://'+city+'.jakdojade.pl/molbas/transit', method:'POST', headers: {
  'Accept':'*/*',
  'Accept-Charset':'ISO-8859-2,utf-8;q=0.7,*;q=0.3',
  'Accept-Language':'pl-PL,pl;q=0.8,en-US;q=0.6,en;q=0.4',
  'Connection':'keep-alive',
  'Content-Length':'246',
  'Content-Type':'text/x-gwt-rpc; charset=UTF-8',
  'Cookie':'agg=2000; JSESSIONID=478A87A33E39F6130DFA4EF607E13CAD',
  'Host':city+'.jakdojade.pl',
  'Origin':'http://'+city+'.jakdojade.pl',
  'Referer':'http://'+city+'.jakdojade.pl/',
  'User-Agent':'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/534.30 (KHTML, like Gecko) Chrome/12.0.742.112 Safari/534.30',
  'X-GWT-Module-Base':'http://'+city+'.jakdojade.pl/molbas/',
  'X-GWT-Permutation':'A489B6773B01EC476C21D1375F26F9BD'
  }, body: '7|0|7|http://'+city+'.jakdojade.pl/molbas/|F92AB3F710683E04BDF8C95AD8C2871F|com.molbas.gwt.client.services.TransitServices|getStopsInArea|J|D|I|1|2|3|4|6|5|6|6|6|6|7|fQ|0.0|90.0|0.0|90.0|17|'},
  function(err, resp, body){
    if(err){
      console.error(err)
    } else {
      console.log(body)
    }
  }
)
