var request = require('request')

for(var i=0; i < 3000; i++){
  var re = /dM\(([0-9]+\.[0-9]+),([0-9]+\.[0-9]+),\'([^\']+)\'/;
  request({uri: "http://62.111.240.236/ajax/getMarker.php?id_przystanku="+i}, function(err, resp, body){
    var match = body.match(re)
    if(match){
      var doc = {type: 'Stop', name: match[3], updated_at: new Date()}
      doc.location = {lat: parseFloat(match[1]), lon: parseFloat(match[2])}

      request({uri: process.argv[2], method: 'POST', json: doc})
      console.log(doc)
    }
  })
}
