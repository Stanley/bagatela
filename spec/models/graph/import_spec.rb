require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')
require 'rspec/mocks/standalone'

include Bagatela::Graph

describe Import do
  let(:source){ "whatever" }
  describe "nodes" do

    RestClient.stub(:get) do
      {:rows => [{:value => {:_id => "Foo"}}]}.to_json
    end
    subject{ Import.nodes!(source) }

    it "should return a hash array" do
      should have(1).item
      should include('Foo')
    end

    it "should initialize Graph::Stop" do
      subject['Foo'].should be_a(Stop)
    end

  end

  describe "connection" do
    describe "to the line's destination" do
      before :all do
        RestClient.stub(:get) do |uri|
          case uri
          when Regexp.new('/_design/Timetables/_view/by_source')
            {:rows => [
              {:value => {'stop'=>'Begin', 'destination'=>'END'}}
            ]}.to_json
          when Regexp.new('/_design/Stops/_view/by_name')
            {:rows => [
              {:value => {'_id' => 'Begin'}},
              {:value => {'_id' => 'End'}}
            ]}.to_json
          end
        end

        @relationships = Import.relationships!(source)
      end

      it "should return an array" do
        @relationships.should have(1).item
      end

      describe "relationship" do
        subject{ @relationships.first }

        it { should be_a(Connection) }

        it "should start at the timetable's stop" do
          subject.start_node.id.should eql('Begin')
        end

        it "should end at the line's destination" do
          subject.end_node.id.should eql('End')
        end

        #describe "length" do
          #it "should equal the distance between those points based on polyline"

          #it "should equal the distance between those points in straight line if polyline isn't provided"
        #end

      end
    end

    describe "to another stop with the same name" do
      before :all do
        RestClient.stub(:get) do |uri|
          case uri
          when Regexp.new('/_design/Timetables/_view/by_source')
            {:rows => [
              {:value => {'stop'=>'Foo', 'destination'=>'FOO', 'line'=>'A'}},
              {:value => {'stop'=>'Foo', 'destination'=>'FOO', 'line'=>'B'}}
            ]}.to_json
          when Regexp.new('/_design/Stops/_view/by_name')
            {:rows => [
              {:value => {'_key' => 'Foo'}},
            ]}.to_json
          end
        end

        @relationships = Import.relationships!(source)
      end

      it "should create a new node" do
        connection = @relationships.first
        connection.start_node.id.should_not eql(connection.end_node.id)
      end

      it "should reuse created node in " do
        @relationships.first.end_node.should eql(@relationships.last.end_node)
      end

    end

    describe "from many timetables" do
      before :all do
        RestClient.stub(:get) do |uri|
          case uri
          when Regexp.new('/_design/Timetables/_view/by_source')
            {:rows => [
              {:value => {
                'stop'=>'Foo',
                'destination'=>'Bar',
                'line'=>'A',
                'tables'=>{'*'=>{'11'=>['11']}}
              }},{:value => {
                'stop'=>'Foo',
                'destination'=>'Bar',
                'line'=>'B',
                'tables'=>{'*'=>{'22'=>['22']}}
              }}
            ]}.to_json
          when Regexp.new('/_design/Stops/_view/by_name')
            {:rows => [
              {:value => {'_id' => 'Foo'}},
              {:value => {'_id' => 'Bar'}}
            ]}.to_json
          end
        end

        @relationships = Import.relationships!(source)
      end

      describe "relationship" do
        subject{ @relationships.first }
        
        it "should merge departures from different timetables" do
          rides = {11*60+11 => {'line'=>'A', 'duration'=>1},
                   22*60+22 => {'line'=>'B', 'duration'=>1}}
          subject.rides.should eql(rides)
        end

      end
    end
  end
end
