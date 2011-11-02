var Pigeons = require('pigeons')
  , fs = require('fs')
  , config = require('./config.js');

fs.readFile(process.argv[2], 'utf-8', function(err, data){
  var conf = JSON.parse(data);
  conf.db = config.couch + conf.code;
  conf.log = config.couch +'logs';
  new Pigeons(conf, function(){
    this.getAll(function(){ console.log('Done.') });
  });
})
