require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'search engine' do
  include Rack::Test::Methods

  def app
    Bagatela.new
  end

  it "should not find random stop" do

    Hub.new :name => "Beginning"
    Neo4j::Transaction.finish

    post '/Beginning:Random'
    last_response.status.should eql(404)
    last_response.body.should be_json

    body = JSON.parse(last_response.body)
    body['error'].should eql("not_found")
    body['reason'].should eql("resource_not_found")
  end

  it "should be cool if beginning is ending" do

    Hub.new :name => "Beginning"
    Neo4j::Transaction.finish

    post '/Beginning:Beginning'
    last_response.status.should eql(400)
    last_response.body.should be_json

    body = JSON.parse(last_response.body)
    body['error'].should eql("bad_request")
    body['reason'].should eql("two_different_stops_required")
  end

  it "should apologize if there is not connection" do

    Hub.new :name => "Beginning", :lat => 0, :lon => 0
    Hub.new :name => "Nowhere",   :lat => 1, :lon => 1
    Neo4j::Transaction.finish

    post '/Beginning:Nowhere'
    last_response.should_not be_ok
    last_response.body.should be_json

    body = JSON.parse(last_response.body)
    body['from'].should eql("Beginning")
    body['to'].should eql("Nowhere")
    body['error'].should eql("not_found")
  end

  it "should find direct connection between two stops" do

    h1 = Hub.new :name => 'Beginning', :lat => 0, :lon => 0
    h2 = Hub.new :name => 'Ending',    :lat => 1, :lon => 1

    direction = h1.connections.new h2
    direction.timetables = {
      12*60     => 2, # departures at 12:00 and arrives two minutes later
      12*60 + 3 => 2, #               12:03
      12*60 + 5 => 2  #               12:05
    }.to_json

    Neo4j::Transaction.finish

    post '/Beginning:Ending', {'time'=>'11:59'}
    last_response.should be_ok
    last_response.body.should be_json

    body = JSON.parse(last_response.body)
    body['from'].should eql("Beginning")
    body['to'].should eql("Ending")
    body['duration'].should eql(3)

    body['results'].should have(2).stops
    body['results'][0].should eql({
      "departure" => "12:00",
      "stop"      => "Beginning"
    })
    body['results'][1].should eql({
      "arrival" => "12:02",
      "stop"    => "Ending"
    })
  end

  it "should find connection with transfer between two stops" do

    h1 = Hub.new :name => 'Begin', :lat => 0, :lon => 0
    h2 = Hub.new :name => 'Transfer', :lat => 1, :lon => 1
    h3 = Hub.new :name => 'End', :lat => 2, :lon => 2


    h1.connections.new(h2).timetables = {
      12*60     => 2, # departures at 12:00 and arrives two minutes later
    }.to_json

    h2.connections.new(h3).timetables = {
      12*60     => 2, # departures at 12:00 and arrives two minutes later
      12*60 + 5 => 2  #               12:05
    }.to_json

    Neo4j::Transaction.finish

    post '/Begin:End', {'time'=>'11:55'}
    last_response.should be_ok
    last_response.body.should be_json

    body = JSON.parse(last_response.body)
    body['duration'].should eql(12)

    body['results'].should have(3).stops
    body['results'][1].should eql({
      "arrival"   => "12:02",
      "departure" => "12:05",
      "stop"      => "Transfer"
    })
    body['results'][2].should eql({
      "arrival" => "12:07",
      "stop"    => "End"
    })
  end

  it "should add a penalty time on transfer"

  describe "heuristics" do

    # Given is the following graph:
    # 1_____2
    # .\....|
    # ..3...|
    # ..|\..|
    # ..\.4.|
    # ...\.\|
    # ....5_6

    before :each do
      h1 = Hub.new :name => 'Hub1', :lat => 0.00, :lon => 0.00
      h2 = Hub.new :name => 'Hub2', :lat => 0.06, :lon => 0.00
      h3 = Hub.new :name => 'Hub3', :lat => 0.02, :lon => 0.02
      h4 = Hub.new :name => 'Hub4', :lat => 0.04, :lon => 0.04
      h5 = Hub.new :name => 'Hub5', :lat => 0.04, :lon => 0.06
      h6 = Hub.new :name => 'Hub6', :lat => 0.06, :lon => 0.06

      direction = h1.connections.new h2
      direction.timetables = {
        12*60     => 1, # departures at 12:00 and arrives one minute later
        12*60 + 3 => 1, #               12:03
        12*60 + 5 => 1  #               12:05
      }.to_json

      direction = h1.connections.new h3
      direction.timetables = {
        12*60 + 1 => 2, # departures at 12:01 and arrives two minutes later
        12*60 + 4 => 2, #               12:04
        12*60 + 7 => 2  #               12:07
      }.to_json

      direction = h2.connections.new h6
      direction.timetables = {
        12*60 + 2 => 2, # departures at 12:02 and arrives two minutes later
        12*60 + 5 => 2, #               12:05
        12*60 + 7 => 2  #               12:07
      }.to_json

      direction = h3.connections.new h4
      direction.timetables = {
        12*60 + 6 => 2, #               12:06
        12*60 + 9 => 2  #               12:09
      }.to_json

      direction = h3.connections.new h5
      direction.timetables = {
        12*60 + 3 => 2, # departures at 12:03 and arrives two minutes later
      }.to_json

      direction = h4.connections.new h6
      direction.timetables = {
        12*60 + 8 => 2, # departures at 12:08 and arrives two minutes later
        12*60 +11 => 2, #               12:11
      }.to_json

      direction = h5.connections.new h6
      direction.timetables = {
        12*60 + 5 => 2, # departures at 12:05 and arrives two minutes later
      }.to_json

      Neo4j::Transaction.finish
    end
  
    it "should find the shortest path between two stops" do

      post '/Hub1:Hub6', {'time'=>'11:59'}
      last_response.should be_ok
      last_response.body.should be_json

      body = JSON.parse(last_response.body)
      body['results'].should have(4).stops
      body['results'].last.should eql({
        "arrival" => "12:10",
        "stop"    => "Hub6" })

      body['duration'].should eql(11)
#      body['distance'].should be_close(GeoCostEvaluator.distance(0,0,6,6), 1)

    end

    it "should find the fastest connection between two stops" do

      post '/Hub1:Hub6', {'time'=>'11:59', 'priority'=>'time'}
      last_response.should be_ok
      last_response.body.should be_json

      body = JSON.parse(last_response.body)
      body['results'].should have(3).stops
      body['results'].last.should eql({
        "arrival" => "12:04",
        "stop"    => "Hub6" })
      
      body['duration'].should eql(5)
#      body['distance'].should be_close(GeoCostEvaluator.distance(0,0,6,0) + GeoCostEvaluator.distance(6,0,6,6), 1)
    end

    it "should find alternative to the shortest path if the waiting time is too long"

  end

end
