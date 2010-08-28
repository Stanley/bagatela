require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'search engine' do
  include Rack::Test::Methods

  def app
    Bagatela.new
  end

  before do
    Neo4j::Transaction.run do
      s1 = Stop.new :name => "Beginning"
      s2 = Stop.new :name => "Ending"
           Stop.new :name => "Nowhere"

      s1.rels.outgoing(:connection) << s2

      r1 = Run.new
      r1.time = [12,0] # 12:00
      r2 = Run.new
      r2.time = [12,2] # 12:02

      r1.rels.outgoing(:connection) << r2
      s1.rels.outgoing(:departures) << r1
      s2.rels.outgoing(:departures) << r2
    end
  end

  it "should not find random stop" do
    post '/Beginning:Random'
    last_response.ok?.should be_true
    last_response.body.should be_json

    body = JSON.parse(last_response.body)
    body['error'].should eql("not_found")
    body['reason'].should eql("stop_does_not_exist")
  end

  it "should be cool if beginning is ending" do
    post '/Beginning:Beginning'
    last_response.ok?.should be_true
    last_response.body.should be_json

    body = JSON.parse(last_response.body)
    body['error'].should eql("not_found")
    body['reason'].should eql("two_different_stops_required")
  end

  it "should apology if there is not connection" do
    post '/Beginning:Nowhere'
    last_response.ok?.should be_true
    last_response.body.should be_json

    body = JSON.parse(last_response.body)
    body['error'].should eql("not_found")
    body['reason'].should eql("no_connection")
  end

  it "should find connection between two stops" do
    post '/Beginning:Ending'
    last_response.ok?.should be_true
    last_response.body.should be_json

    body = JSON.parse(last_response.body)
    body['ok'].should be_true
  end
end