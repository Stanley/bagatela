var sys = require('sys')
    http = require('http'),
    httpAgent = require('http-agent'),
    jsdom = require('jsdom'),
    couchdb = require('couchdb');

var window = jsdom.jsdom().createWindow();
    
var client = couchdb.createClient(5984, 'localhost'),
    db = client.db('krapi');

var mpk = http.createClient(80, 'rozklady.mpk.krakow.pl'),
    home = mpk.request('GET', '/linie.aspx', {'host': 'rozklady.mpk.krakow.pl'});

home.end();
home.on('response', function (response) {

  var body = "";

  response.on('data', function(chunk) {
    body += chunk
  });
  
  response.on('end', function(){
  
    var window = jsdom.jsdom(body).createWindow();
    jsdom.jQueryify(window, './jquery.js', function (window, $) {

      var lines = $('a[HREF$=htm]').map(function(){
        return $(this).attr('HREF').replace('rw', 'w0');
      });

      var bot = httpAgent.create('rozklady.mpk.krakow.pl', lines.get());
      var visited = lines.get()
      
      bot.addListener('next', function(err, agent){

        if (err) throw new Error(JSON.stringify(err));
        sys.puts(agent.url)
        
        var window = jsdom.jsdom(agent.body).createWindow();

        jsdom.jQueryify(window, './jquery.js', function (window, $) {
        
          var timetables = $('a[href][target="R"]');
          if(timetables.length){
            timetables.each(function(){
              var base = agent.url.split('/');
              var uri = base.slice(0, base.length-1).join('/') +'/'+ $(this).attr('href')
              if(visited.indexOf(uri) == -1){
//                bot.next(uri);
                bot.addUrl(uri);
                visited.push(uri);
              }
            });
          
            // Oposite directions
            $("a[target='_parent']:not(:contains(*))").each(function(){
              var base = agent.url.split('/');
              var uri = base.slice(0, base.length-1).join('/') +'/'+ $(this).attr('href').replace('rw', 'w0')
              if(visited.indexOf(uri) == -1){
                bot.addUrl(uri);
                visited.push(uri);
              }
            });
          } else {
                    
            var table = $('table[border=1]');
            if(table.length){
              
              var doc = {},
                  re = /\d{2}.\d{2}.\d{4}/,
                  txt = $('table[border=1] tr:last-child b:first').text(), // TODO workaround
                  m = re.exec(txt);
              
              doc['url'] = agent.url;
              doc['headers'] = agent.response.headers;            
              doc['line'] = $('table tr:first-child table tr:first-child td:first-child font').text();
              doc['stop'] = $("table tr:first-child table tr:first-child td:first-child+td font:first-child").text();
              doc['route'] = $("table tr:first-child table tr:first-child td:first-child+td font:not(:first-child)").text();
              doc['valid_since'] = m ? m[0] : txt;
              doc['created_at'] = new Date();
              doc['table'] = {};
              
              $("table[border=1] tr:first-child font").each(function(i){ // TODO workaround
                var key = $(this).text();
                doc['table'][key] = {};
                $('table[border=1] tr:not(:first-child, :last-child) td:nth-child('+ (i*2+1) +')').each(function(){
                  var self = $(this);
                  var minutes = self.next().text().split(" ");
                  minutes.shift();
                  
                  if(minutes != ["-"])
                    doc['table'][key][self.text()] = minutes;
                });
              });
              
              db.saveDoc(doc, function(er, ok) {
                if (er) throw new Error(JSON.stringify(er));
                sys.puts(JSON.stringify(ok))
              });
            }
          }
          bot.next();
        });
      });
      bot.start()
    });
  });
});

