require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')
include Bagatela::Graph

describe Hub do

  it "should validate presence of name" do
    hub = Neo4j::Transaction.run do
      Hub.new
    end

    hub.should_not be_valid
    hub.errors.on(:name).should eql("Name can't be blank")
  end

  #it "should index hub's names" do
    #Neo4j::Transaction.run do
      #hub_1 = Hub.new :name => 'Anywhere', :lat => 1, :lng => 2
      #hub_2 = Hub.new :name => 'Somewhere', :lat => 3, :lng => 4
    #end

    #search_1 = Hub.find(:name=>'Anywhere').size.should eql(1)
    #search_1[0].props.should eql(hub_1.props)

    #search_2 = Hub.find(:name=>'SOMEWHERE').size.should eql(1)
    #search_2[0].props.should eql(hub_2.props)
  #end

end
