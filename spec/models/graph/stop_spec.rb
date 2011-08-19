require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')
include Bagatela::Graph

describe Stop do

  it "should validate presence of geo position" do
    hub = Neo4j::Transaction.run do
      Hub.new :name => 'Nowhere'
    end

    hub.should_not be_valid
    hub.errors.on(:lat).should eql("Latitude can't be blank")
    hub.errors.on(:lon).should eql("Longitude can't be blank")
  end

  it "should validate numericality of lat and lon" do
    hub = Neo4j::Transaction.run do
      Hub.new :name => 'Somewhere', :lat => 'foo', :lng => []
    end

    hub.should_not be_valid
    hub.errors.on(:lat).should eql("must be a number")
    hub.errors.on(:lon).should eql("must be a number")
  end

end
