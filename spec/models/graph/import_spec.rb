require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')
require 'rspec/mocks/standalone'

include Bagatela::Graph

describe Import do
  let(:source){ "whatever" }
  describe "nodes" do

    RestClient.stub(:get) do
      {:rows => [{:value => {'_key' => ['Foo']}}]}.to_json
    end
    subject{ Import.nodes!(source, true) }

    it "should return a hash array" do
      should have(1).item
      should include('FOO')
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

        @relationships = Import.relationships!(source)
      end

      it "should return an array" do
        @relationships.should have(1).item
      end

      describe "relationship" do

        it "should start at the timetable's stop" do
          @relationships.should include('a')
        end

        it "should end at the line's destination" do
          @relationships['a'].should include('FOO')
        end

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

        @relationships = Import.relationships!(source, true)
      end

      it "should create a new node" do
        @relationships['FOO'].should_not include('FOO')
      end

      it "should reuse created node in parallel lines" do
        @relationships['FOO'].should have(1).item
      end

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

        @relationships = Import.relationships!(source)
      end

      describe "relationship" do
        subject{ @relationships.values.map{|x| x.values}.flatten.first }
        
        it "should merge departures from different timetables" do
          departures = JSON.parse(subject['departures'])
          #departures = MessagePack.unpack(subject['departures'])
          
          departures.should include(11*60+11)
          departures.should include(22*60+22)
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

        Import.relationships!(source).should be_empty
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

        Import.relationships!(source)["b"].should include("c")
      end
    end

  end
end
