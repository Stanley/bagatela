require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'search engine' do
  include Rack::Test::Methods

  def app
    Bagatela.new
  end

  it "should not find random stop" do

    Stop.new :name => "Beginning"
    Neo4j::Transaction.finish

    post '/Beginning:Random'
    last_response.status.should eql(404)
    last_response.body.should be_json

    body = JSON.parse(last_response.body)
    body['error'].should eql("not_found")
    body['reason'].should eql("resource_not_found")
  end

  it "should be cool if beginning is ending" do

    Stop.new :name => "Beginning"
    Neo4j::Transaction.finish

    post '/Beginning:Beginning'
    last_response.status.should eql(400)
    last_response.body.should be_json

    body = JSON.parse(last_response.body)
    body['error'].should eql("bad_request")
    body['reason'].should eql("two_different_stops_required")
  end

  it "should apologize if there is not connection" do

    Stop.new :name => "Beginning"
    Stop.new :name => "Nowhere"
    Neo4j::Transaction.finish

    post '/Beginning:Nowhere'
    last_response.ok?.should be_true
    last_response.body.should be_json

    body = JSON.parse(last_response.body)
    body['error'].should eql("not_found")
    body['reason'].should eql("no_connection")
  end

  it "should find direct connection between two stops" do

    s1 = Stop.new :name => "Beginning"
    s2 = Stop.new :name => "Ending"

    s1.rels.outgoing(:connections) << s2

    r1 = Run.new
    r1.time = [12,0] # 12:00
    r2 = Run.new
    r2.time = [12,2] # 12:02

    r1.rels.outgoing(:connection) << r2
    s1.rels.outgoing(:departures) << r1
    s2.rels.outgoing(:departures) << r2

    Neo4j::Transaction.finish

    post '/Beginning:Ending'
    last_response.ok?.should be_true
    last_response.body.should be_json

    body = JSON.parse(last_response.body)
    body['from'].should eql("Beginning")
    body['to'].should eql("Ending")
    body['duration'].should eql(2)

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

  it "should find connection with transfer between two stops"

  it "should find the fastest connection between two stops"
end