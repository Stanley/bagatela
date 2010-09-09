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
    last_response.should be_ok
    last_response.body.should be_json

    body = JSON.parse(last_response.body)
    body['from'].should eql("Beginning")
    body['to'].should eql("Nowhere")
    body['results'].should be_empty
  end

  it "should find direct connection between two stops" do

    h1 = Hub.new :name => 'Beginning', :lat => 0, :lon => 0
    h2 = Hub.new :name => 'Ending',    :lat => 1, :lon => 1

    direction = h1.connects.new h2
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


    h1.connects.new(h2).timetables = {
      12*60     => 2, # departures at 12:00 and arrives two minutes later
    }.to_json

    h2.connects.new(h3).timetables = {
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
      h1 = Hub.new :name => 'Hub1', :lat => 0, :lon => 0
      h2 = Hub.new :name => 'Hub2', :lat => 6, :lon => 0
      h3 = Hub.new :name => 'Hub3', :lat => 2, :lon => 2
      h4 = Hub.new :name => 'Hub4', :lat => 4, :lon => 4
      h5 = Hub.new :name => 'hub5', :lat => 4, :lon => 6
      h6 = Hub.new :name => 'hub6', :lat => 6, :lon => 6

      direction = h1.connects.new h2
      direction.timetables = {
        12*60     => 2, # departures at 12:00 and arrives two minutes later
        12*60 + 3 => 2, #               12:03
        12*60 + 5 => 2  #               12:05
      }.to_json

      direction = h1.connects.new h3
      direction.timetables = {
        12*60 + 1 => 2, # departures at 12:01 and arrives two minutes later
        12*60 + 4 => 2, #               12:04
        12*60 + 7 => 2  #               12:07
      }.to_json

      direction = h2.connects.new h6
      direction.timetables = {
        12*60 + 2 => 2, # departures at 12:02 and arrives two minutes later
        12*60 + 5 => 2, #               12:05
        12*60 + 7 => 2  #               12:07
      }.to_json

      direction = h3.connects.new h4
      direction.timetables = {
        12*60 + 6 => 2, #               12:06
        12*60 + 9 => 2  #               12:09
      }.to_json

      direction = h3.connects.new h5
      direction.timetables = {
        12*60 + 3 => 2, # departures at 12:03 and arrives two minutes later
      }.to_json

      direction = h4.connects.new h6
      direction.timetables = {
        12*60 + 8 => 2, # departures at 12:08 and arrives two minutes later
        12*60 +11 => 2, #               12:11
      }.to_json

      direction = h5.connects.new h6
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
      body['duration'].should eql(6)
      body['distance'].should be_close(GeoCostEvaluator.distance(0,0,6,6), 1)

      body['results'].should have(4).stops
      body['results'].last.should eql({
        "arrival" => "12:13",
        "stop"    => "Hub6"
      })
     
    end

    it "should find the fastest connection between two stops" do

      post '/Hub1:Hub6', {'time'=>'11:59', 'priority'=>'time'}
      last_response.should be_ok
      last_response.body.should be_json

      body = JSON.parse(last_response.body)
      body['duration'].should eql(6)
      body['distance'].should be_close(GeoCostEvaluator.distance(0,0,6,0) + GeoCostEvaluator.distance(6,0,6,6), 1)

      body['results'].should have(3).stops
      body['results'].last.should eql({
        "arrival" => "12:04",
        "stop"    => "Hub6"
      })
    end

  end
end
