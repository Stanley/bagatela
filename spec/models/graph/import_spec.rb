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
          when Regexp.new('/_design/Timetables/_view/by_source')
            {:rows => [
              {:value => {'stop_id'=>'a', 'destination'=>'Foo', 'tables'=>{}}}
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
          when Regexp.new('/_design/Timetables/_view/by_source')
            {:rows => [
              {:value => {'stop'=>'Foo', 'destination'=>'FOO', 'line'=>'A', 'tables'=>{}}},
              {:value => {'stop'=>'Foo', 'destination'=>'FOO', 'line'=>'B', 'tables'=>{}}}
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
          when Regexp.new('/_design/Timetables/_view/by_source')
            {:rows => [
              {:value => {
                'stop_id'=>'a',
                'destination'=>'Bar',
                'line'=>'A',
                'tables'=>{'*'=>{'11'=>['11']}}
              }},{:value => {
                'stop_id'=>'a',
                'destination'=>'Bar',
                'line'=>'B',
                'tables'=>{'*'=>{'22'=>['22']}}
              }}
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
          rides = {11*60+11 => {'line'=>'A', 'duration'=>1},
                   22*60+22 => {'line'=>'B', 'duration'=>1}}
          MessagePack.unpack(subject['rides']).should eql(rides)
        end

      end
    end

  end
end
