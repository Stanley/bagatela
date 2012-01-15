Bagatela - wyszukiwarka połączeń komunikacji miejskiej ![still maintained](http://stillmaintained.com/jeffkreeftmeijer/stillmaintained.png)
======================================================

Bagatela udostępnia interfejs programistyczny do wyszukiwania przystanków i optymalnych połączeń w sieci komunikacji miejskiej.

Zanim zaczniesz czytać dalej
----------------------------

**To nie jest skończony projekt. Uruchom testy aby zobaczyć aktualny stan pracy.**

Wykorzystywane technologie
--------------------------

* Język programowania: [Ruby](http://www.ruby-lang.org/) (implementacja [JRuby](http://jruby.org/))
* Testing frameworks: [Cucumber](http://cukes.info) i [RSpec](http://rspec.info/)
* Bazy danych: połączeń [OrientDB](http://orientechnologies.com) i rozkładów jazdy [CouchDB](http://couchdb.apache.org)
* Serwer HTTP: [Rexster](https://github.com/tinkerpop/rexster/wiki/)
* Full-text search: [Elasticsearch](http://www.elasticsearch.org/)

Instalacja
----------

Ustaw domyślny interpreter Ruby na JRuby (jeżeli korzystasz z [rbenv](https://github.com/sstephenson/rbenv) stanie się to automatycznie gdy znajdziesz się w folderze projektu). Jeżeli korzystasz z [Ruby Version Manager](http://rvm.beginrescueend.com/) wykonaj:

    $ rvm use jruby
    Using jruby 1.6.3

Ustaw tryb kompatybilności z Ruby 1.9:

    $ export JRUBY_OPTS=--1.9

Ściągnij repozytorium i zainstaluj niezbędne biblioteki (wymagany [bundler](http://gembundler.com/)) ![Gemnasium](https://gemnasium.com/Stanley/bagatela.png):

    $ git clone git://github.com/Stanley/bagatela.git
    $ cd bagatela
    $ bundle install

Populacja bazy danych
---------------------

* Opcja 1: 

  Replikuj jedną z oficjalnych baz danych. Np.:

        $ curl -X POST http://api.bagate.la/_replicate -d '{"source":"kr","target":"http://localhost:5984/kr"}'

* Opcja 2:

  Importuj rozkłady bezpośrednio ze źródła (tj. strony przewoźnika). Zobacz projekt [pigeons](https://github.com/Stanley/pigeons) po więcej informacji.

* Opcja 3:

  Przebiegnij po wszystkich przystankach w mieście, zapisując odjazdy w notesie. Przepisz do komputera.

Generacja grafu
---------------

Kolejnym krokiem przed uruchomieniem wyszukiwarki jest generacja grafu, połączonej struktury przystanków i relacji mnędzy nimi. _Funkcjonalność jest w trakcie tworzenia. Może nie działać._

    $ bundle exec irb -r lib/bagatela.rb
    irb(main):001:0> Bagatela::Graph::Import.new("http://localhost:5984/kr", true).relationships!(Date.parse("23.09.2011")
    
~~Zobacz dokumentację wyjaśniającą agrumenty obu metod~~ (wkrótce).

Uruchomienie
------------

* Testów:

        $ bundle exec cucumber features/

  Uwaga: domyślnie test przeprowadzony jest na `http://localhost:8000`. Z powodu braku praw do zapisu, zmiana tego parametru na `http://api.bagate.la` w pliku `features/support/env.rb` nie ma sensu (choć teoretycznie jest możliwa). W przyszłości w systemie produkcyjnym zostanie udostępniony jeden użytkownik i baza danych do celów testowych. Testy wymagają uruchomionej bazy CouchDB.

        $ bundle exec rspec spec/

  Uwaga: jeżeli chcesz przywrócić wyświetlanie backtrace, które domyślnie jest wyłączone, zakomentuj `:raise_errors` na początku deklaracji klasy `Bagatela::RestApi` w `app/main.rb`. 

* Aplikacji:

        $ PATH_TO_REXSTER/rexster.sh --start -c config/rexster.xml

* Konsoli:

        $ bundle exec irb -r lib/bagatela.rb

Dokumentacja API
----------------

<http://developer.bagate.la/GRAPH.1.html>

Have fun!
