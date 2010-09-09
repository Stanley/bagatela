require File.join(File.dirname(__FILE__), 'spec_helper')

describe Hub do

  it "should validate presence of name" do
    hub = Hub.new
    Neo4j::Transaction.finish

    hub.should_not be_valid
    hub.errors.on(:name).should eql("Name can't be blank")
  end

  it "should validate presence of geo position" do
    hub = Hub.new :name => 'Nowhere'
    Neo4j::Transaction.finish

    Hub.find(:name=>'nowhere').should be_empty
    hub.should_not be_valid
    hub.errors.on(:lat).should eql("Latitude can't be blank")
    hub.errors.on(:lon).should eql("Longitude can't be blank")
  end

  it "should validate numericality of lat and lon" do
    hub = Hub.new :name => 'Somewhere', :lat => 'foo', :lng => []
    Neo4j::Transaction.finish

    hub.should_not be_valid
    hub.errors.on(:lat).should eql("must be a number")
    hub.errors.on(:lon).should eql("must be a number")
  end

  it "should index hub's names" do
    hub_1 = Hub.new :name => 'Anywhere', :lat => 1, :lng => 2
    hub_2 = Hub.new :name => 'Somewhere', :lat => 3, :lng => 4
    Neo4j::Transaction.finish

    search_1 = Hub.find(:name=>'Anywhere').size.should eql(1)
    search_1[0].props.should eql(hub_1.props)

    search_2 = Hub.find(:name=>'SOMEWHERE').size.should eql(1)
    search_2[0].props.should eql(hub_2.props)
  end
end
