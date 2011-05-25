Bagatela - wyszukiwarka połączeń komunikacji miejskiej.
=======================================================

Bagatela udostępnia interfejs programistyczny do wyszukiwania przystanków i optymalnych połączeń w sieci komunikacji miejskiej.

Wykorzystywane technologie
--------------------------

* Język programowania: [Ruby](http://www.ruby-lang.org/) (implementacja [JRuby](http://jruby.org/))
* Web framework: [Sinatra.rb](http://www.sinatrarb.com/)
* Testing frameworks: [Cucumber](http://cukes.info) i [RSpec](http://rspec.info/) + [Rack::Test](http://brynary.github.com/rack-test/)
* Bazy danych: połączeń [Neo4j](http://neo4j.org/) i rozkładów jazdy [CouchDB](http://couchdb.apache.org)
* Small-text search: [Picky](http://github.com/floere/picky)

Zanim zaczniesz czytać dalej
----------------------------

To nie jest skończony projekt. Uruchom testy aby zobaczyć aktualny stan pracy.

Instalacja
----------

Ustaw domyślny interpreter ruby na jruby (jeżeli nie korszystasz z [Ruby Version Manager](http://rvm.beginrescueend.com/) - [zainstaluj](http://rvm.beginrescueend.com/rvm/install/)):

    $ rvm use jruby
    info: Using jruby 1.5.2

Ściągamy repozytorium i zainstalemy niezbędne pakiety (wymagany [git](http://git-scm.com/) i [bundler](http://gembundler.com/):)

    $ git clone http://github.com/Stanley/bagatela
    $ cd bagatela
    $ bundle install

Populacja bazy danych
---------------------

* Opcja 1: 

  Replikuj jedną z oficjalnych baz danych. Np.:

        $ curl -X POST http://api.bagate.la/_replicate -d '{"source":"kr","target":"http://localhost:5984/kr"}'

* Opcja 2:

  Importuj rozkłady bezpośrednio ze źródła (strony przewoźnika):

        $ node import.js

* Opcja 3:

  Przebiegnij po wszystkich przystankach w mieście, zapisując odjazdy w notesie. Przepisz do komputera.

Uruchomienie
------------

* Aplikacji:

        $ rackup

* Testów:

        $ bundle exec cucumber features/

        $ bundle exec spec spec/

  Uwaga: jeżeli chcesz przywrócić wyświetlanie backtrace, które domyślnie jest wyłączone, zakomentuj `:raise_errors` na początku deklaracji klasy `Bagatela` w `app/main.rb`. 

* Konsoli:

        $ bundle exec irb -r app/main.rb

Dokumentacja API
----------------

<http://stanley.github.com/bagatela>
