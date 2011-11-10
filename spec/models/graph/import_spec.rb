require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')
require 'rspec/mocks/standalone'

include Bagatela::Graph

describe Import do
  #describe "nodes" do

    #RestClient.stub(:get) do
      #{:rows => [{:value => {'_key'=>['Foo'],'name'=>'Bar'}}]}.to_json
    #end
    #subject{ Import.new(nil).nodes!(true) }

    #it "should return a hash array" do
      #should have(1).item
      #should include('FOO')
    #end

  #end

  describe "order" do
    it "should not be solely based on first departure" do
      RestClient.stub(:get) do |uri|
        case uri
        when Regexp.new('/_design/Timetables/_view/by_line')
          {:rows => [
            {:value => {:_key=>['L','FOO'], :stop_id=>'a', :tables=>{'*'=>{'0'=>['00','10']}}}},
            {:value => {:_key=>['L','FOO'], :stop_id=>'b', :tables=>{'*'=>{'0'=>['04','14']}}}},
            {:value => {:_key=>['L','FOO'], :stop_id=>'c', :tables=>{'*'=>{'0'=>['01','08']}}}},
            {:value => {:_key=>['L','FOO'], :stop_id=>'d', :tables=>{'*'=>{'0'=>['05','12']}}}}
          ]}.to_json
        when Regexp.new('/_design/Stops/_view/by_name')
          {:rows => [
            {:value => {:_id => 'a'}},
            {:value => {:_id => 'b'}},
            {:value => {:_id => 'c'}},
            {:value => {:_id => 'd'}}
          ]}.to_json
        end
      end
      
      relationships = Import.new(nil).relationships!

      relationships.should have_key(['a','b'])
      relationships.should have_key(['b','c'])
      relationships.should have_key(['c','d'])
    end
  end

  describe "connection" do
    describe "to the line's destination" do
      before :all do
        RestClient.stub(:get) do |uri|
          case uri
          when Regexp.new('/_design/Timetables/_view/by_line')
            {:rows => [
              {:value => {:_key=>['L','Foo'], :stop_id=>'a', :tables=>{'*'=>{'0'=>['00']}}}}
            ]}.to_json
          when Regexp.new('/_design/Stops/_view/by_name')
            {:rows => [
              {:value => {:_id => 'a', :name => 'Bar'}},
              {:value => {:_id => 'b', :name => 'Foo', :finish => true}}
            ]}.to_json
          end
        end

        @relationships = Import.new(nil).relationships!
      end

      it "should start at the timetable's stop" do
        @relationships.should have_key(['a','FOO'])
      end
    end

    describe "to another stop with the same name" do
      before :all do
        RestClient.stub(:get) do |uri|
          case uri
          when Regexp.new('/_design/Timetables/_view/by_line')
            {:rows => [
              {:value => {:_key=>['A','FOO'], :stop=>'Foo', :tables=>{'*'=>{'0'=>['00']}}}},
              {:value => {:_key=>['B','FOO'], :stop=>'Foo', :tables=>{'*'=>{'0'=>['00']}}}}
            ]}.to_json
          when Regexp.new('/_design/Stops/_view/by_name')
            {:rows => [
              {:value => {:_key => ['Foo']}},
            ]}.to_json
          end
        end

        @relationships = Import.new(nil,true).relationships!
      end

      #it "should create a new node" do
        #@relationships.should_not have_key(['FOO','FOO'])
      #end

      #it "should reuse created node in parallel lines" do
        #@relationships.should have_key(['FOO','FOO+1'])
      #end

    end

    describe "from many timetables" do
      before :all do
        RestClient.stub(:get) do |uri|
          case uri
          when Regexp.new('/_design/Timetables/_view/by_line')
            {:rows => [
              {:value => {:_key=>['A','Bar'], :stop_id=>'a', :tables=>{'*'=>{'11'=>['11']}} }},
              {:value => {:_key=>['B','Bar'], :stop_id=>'a', :tables=>{'*'=>{'22'=>['22']}} }}
            ]}.to_json
          when Regexp.new('/_design/Stops/_view/by_name')
            {:rows => [
              {:value => {:_id => 'a', :name => ''}},
              {:value => {:_id => 'b', :name => 'Bar', :finish => true}}
            ]}.to_json
          end
        end

        @relationships = Import.new(nil).relationships!
      end

      describe "relationship" do
        subject{ @relationships.values.first }
        
        it "should merge departures from different timetables" do
          departures = JSON.parse(subject['departures'])
          #departures = MessagePack.unpack(subject['departures'])
          
          departures.should have_key((11*60+11).to_s)
          departures.should have_key((22*60+22).to_s)
          #departures.should have_key(11*60+11)
          #departures.should have_key(22*60+22)
        end

      end
    end

    describe "from empty table" do
      it "should not be created" do
        RestClient.stub(:get) do |uri|
          case uri
          when Regexp.new('/_design/Timetables/_view/by_line')
            {:rows => [
              {:value => {:_key=>['A','Foo'], :stop_id=>'a', :tables=>{}}},
            ]}.to_json
          when Regexp.new('/_design/Stops/_view/by_name')
            {:rows => [
              {:value => {:_id => 'a', :name => 'Bar'}},
              {:value => {:_id => 'b', :name => 'Foo', :finish => true}}
            ]}.to_json
          end
        end

        Import.new(nil).relationships!.should be_empty
      end
    end

    describe "loop" do
      it "can not exist" do
        RestClient.stub(:get) do |uri|
          case uri
          when Regexp.new('/_design/Timetables/_view/by_line')
            {:rows => [
              {:value => {:_key=>['A','Baz'], :stop_id=>'a', :tables=>{"*"=>{"12"=>["00","10","50"]}}}},
              {:value => {:_key=>['A','Baz'], :stop_id=>'b', :tables=>{"*"=>{"12"=>["02","12"]}}}}
            ]}.to_json
          when Regexp.new('/_design/Stops/_view/by_name')
            {:rows => [
              {:value => {:_id => 'a', :name => 'Bar'}},
              {:value => {:_id => 'b', :name => 'Foo'}},
              {:value => {:_id => 'c', :name => 'Baz', :finish=>true}}
            ]}.to_json
          end
        end

        Import.new(nil).relationships!.should have_key(["b","BAZ"])
      end
    end
  end

  # Edge cases

  describe "line which has some runs that doesn't start at the first stop nor end at the last one" do
    it "should replace weakest connection with larger segment" do
      RestClient.stub(:get) do |uri|
        case uri
        when Regexp.new('/_design/Timetables/_view/by_line')
          {:rows => [
            {:value => {:_key=>['A','Baz'], :stop_id=>'a', :tables=>{"*"=>{"12"=>["00","10"]}}}},
            {:value => {:_key=>['A','Baz'], :stop_id=>'b', :tables=>{"*"=>{"12"=>["01","11"]}}}},
            {:value => {:_key=>['A','Baz'], :stop_id=>'c', :tables=>{"*"=>{"12"=>["03","13","23"]}}}},
            {:value => {:_key=>['A','Baz'], :stop_id=>'d', :tables=>{"*"=>{"12"=>["04","14"]}}}}
          ]}.to_json
        when Regexp.new('/_design/Stops/_view/by_name')
          {:rows => [
            {:value => {:_id => 'a', :name => 'A'}},
            {:value => {:_id => 'b', :name => 'B'}},
            {:value => {:_id => 'c', :name => 'C'}},
            {:value => {:_id => 'c', :name => 'D'}}
          ]}.to_json
        end
      end

      relationships = Import.new(nil).relationships!
      relationships.should have_key(['a','b'])
      relationships.should have_key(['b','c'])
      relationships.should have_key(['c','d'])
      relationships.should_not have_key(['b','d'])
    end

    it "should not replace weakest connection if new would be even worst" do
      RestClient.stub(:get) do |uri|
        case uri
        when Regexp.new('/_design/Timetables/_view/by_line')
          {:rows => [
            {:value => {:_key=>['L','Foo'], :stop_id=>'a', :tables=>{"*"=>{"12"=>["00","10","20"]}}}},
            {:value => {:_key=>['L','Foo'], :stop_id=>'b', :tables=>{"*"=>{"12"=>["01","11","21"]}}}},
            {:value => {:_key=>['L','Foo'], :stop_id=>'c', :tables=>{"*"=>{"12"=>["02","13","19","30"]}}}},
            {:value => {:_key=>['L','Foo'], :stop_id=>'d', :tables=>{"*"=>{"12"=>["04","14","24"]}}}},
            {:value => {:_key=>['L','Foo'], :stop_id=>'e', :tables=>{"*"=>{"12"=>["05","15","25"]}}}}
          ]}.to_json
        when Regexp.new('/_design/Stops/_view/by_name')
          {:rows => [
            {:value => {:_id => 'a'}},
            {:value => {:_id => 'b'}},
            {:value => {:_id => 'c'}},
            {:value => {:_id => 'd'}},
            {:value => {:_id => 'e'}}
          ]}.to_json
        end
      end

      relationships = Import.new(nil).relationships!
      relationships.should have_key(['b','d'])
      relationships.should_not have_key(['b','c'])
      relationships.should_not have_key(['c','d'])
    end
  end

  describe "line which has an alternative route" do
    it "should split up at n-th stop and join at n+1-th" do
      RestClient.stub(:get) do |uri|
        case uri
        when Regexp.new('/_design/Timetables/_view/by_line')
          {:rows => [
            {:value => {:_key=>['A','Baz'], :stop_id=>'a', :tables=>{"*"=>{"12"=>["00","10","20"]}}}},
            {:value => {:_key=>['A','Baz'], :stop_id=>'b', :tables=>{"*"=>{"12"=>["12"]}}}},
            {:value => {:_key=>['A','Baz'], :stop_id=>'c', :tables=>{"*"=>{"12"=>["02","15","22"]}}}},
            {:value => {:_key=>['A','Baz'], :stop_id=>'d', :tables=>{"*"=>{"12"=>["03","16","23"]}}}}
          ]}.to_json
        when Regexp.new('/_design/Stops/_view/by_name')
          {:rows => [
            {:value => {:_id => 'a', :name => 'A'}},
            {:value => {:_id => 'b', :name => 'B'}},
            {:value => {:_id => 'c', :name => 'C'}},
            {:value => {:_id => 'd', :name => 'D'}}
          ]}.to_json
        end
      end

      relationships = Import.new(nil).relationships!
      relationships.should have_key(['a','b'])
      relationships.should have_key(['a','c'])
      relationships.should have_key(['b','c'])
      relationships.should have_key(['c','d'])
      relationships.should have_key(['d','BAZ'])
    end

    #it "should not split up if not all n-th stop departures arrive at candidate stop" do
      #RestClient.stub(:get) do |uri|
        #case uri
        #when Regexp.new('/_design/Timetables/_view/by_line')
          #{:rows => [
            #{:value => {:_key=>['A','Baz'], :stop_id=>'a', :tables=>{"*"=>{"12"=>["10","20","30"]}}}},
            #{:value => {:_key=>['A','Baz'], :stop_id=>'b', :tables=>{"*"=>{"12"=>["09","21"]}}}},
            #{:value => {:_key=>['A','Baz'], :stop_id=>'c', :tables=>{"*"=>{"12"=>["12","23","32"]}}}}
          #]}.to_json
        #when Regexp.new('/_design/Stops/_view/by_name')
          #{:rows => [
            #{:value => {:_id => 'a', :name => 'A'}},
            #{:value => {:_id => 'b', :name => 'B'}},
            #{:value => {:_id => 'c', :name => 'C'}}
          #]}.to_json
        #end
      #end

      #relationships = Import.new(nil).relationships!
      #relationships.should have_key(['a','c'])
      #relationships.should_not have_key(['a','b'])
      #relationships.should_not have_key(['b','c'])
    #end

    it "should join two fitting segments even if they are separated by another segment" do
      RestClient.stub(:get) do |uri|
        case uri
        when Regexp.new('/_design/Timetables/_view/by_line')
          {:rows => [
            {:value => {:_key=>['A','Baz'], :stop_id=>'a', :tables=>{"*"=>{"12"=>["10","20","30"]}}}},
            {:value => {:_key=>['A','Baz'], :stop_id=>'b', :tables=>{"*"=>{"12"=>["12","22"]}}}},
            {:value => {:_key=>['A','Baz'], :stop_id=>'c', :tables=>{"*"=>{"12"=>["15","25","32"]}}}}
          ]}.to_json
        when Regexp.new('/_design/Stops/_view/by_name')
          {:rows => [
            {:value => {:_id => 'a', :name => 'A'}},
            {:value => {:_id => 'b', :name => 'B'}},
            {:value => {:_id => 'c', :name => 'C'}}
          ]}.to_json
        end
      end

      relationships = Import.new(nil).relationships!
      relationships.should have_key(['a','b'])
      relationships.should have_key(['b','c'])
      relationships.should have_key(['a','c'])
    end

    it "should create diamond" do
      RestClient.stub(:get) do |uri|
        case uri
        when Regexp.new('/_design/Timetables/_view/by_line')
          {:rows => [
            {:value => {:_key=>['A','Baz'], :stop_id=>'a', :tables=>{"*"=>{"12"=>["10","20","30","40","50"]}}}},
            {:value => {:_key=>['A','Baz'], :stop_id=>'b', :tables=>{"*"=>{"12"=>["15","34"]}}}},
            {:value => {:_key=>['A','Baz'], :stop_id=>'c', :tables=>{"*"=>{"12"=>["21","42","52"]}}}},
            {:value => {:_key=>['A','Baz'], :stop_id=>'d', :tables=>{"*"=>{"12"=>["17","23","37","43","53"]}}}}
          ]}.to_json
        when Regexp.new('/_design/Stops/_view/by_name')
          {:rows => [
            {:value => {:_id => 'a', :name => 'A'}},
            {:value => {:_id => 'b', :name => 'B'}},
            {:value => {:_id => 'c', :name => 'C'}},
            {:value => {:_id => 'd', :name => 'D'}}
          ]}.to_json
        end
      end

      relationships = Import.new(nil).relationships!
      relationships.should have_key(['a','b'])
      relationships.should have_key(['a','c'])
      relationships.should have_key(['b','d'])
      relationships.should have_key(['c','d'])
    end

  end

  describe "line score" do
  end
end
