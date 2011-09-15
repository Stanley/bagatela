var Pigeons = require('pigeons')
  , fs = require('fs')

var db = 'http://localhost:5984';

fs.readFile(process.argv[2], 'utf-8', function(err, data){
  var config = JSON.parse(data);
  config.db = db +'/'+ config.code;
  config.log = db +'/logs';
  new Pigeons(config, function(){
    this.getAll(function(){ console.log('Done.') });
  });
})
