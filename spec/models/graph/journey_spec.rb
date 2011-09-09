require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')
include Bagatela::Graph

describe Journey do

  before do
    @start = Object.new
    @relationship = Object.new
  end

  subject do
    Journey.new(@start, {720 => @relationship})
  end

  it "should have nodes" do
    finish = Object.new
    @relationship.expects(:end_node).returns(finish)
    subject.nodes.should eql([@start, finish])
  end

  it "should have relationships" do
    subject.relationships.should eql([@relationship])
  end

  it "should have arrival time" do
    Neo4j::Config[:storage_path] = "2011-09-08"
    @relationship.expects(:next_run).
      with(720).returns([720,5])
    subject.arrival.should eql(Time.parse "2011-09-08 12:05")
  end
end
