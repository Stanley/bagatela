require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')
require 'rspec/mocks/standalone'

include Bagatela::Data

describe Resource do
  it "should initialize from Hash" do
    Resource.new({'foo' => 'bar'})['foo'].should eql('bar')
  end

  describe "couchdb view" do

    it "should generate correct url" do
      uri = "#{COUCHDB}/_design/Foo/_view/bar?param=value"
      RestClient.should_receive(:get).with(uri).and_return('{"rows":[]}')
      Resource.view(:bar, {:param => :value})
    end

    it "should return Array of called class instancies" do
      class Foo < Resource; end
      RestClient.stub(:get){ '{"rows":[{"value":{"_id":"bar"}}]}' }
      Foo.view(:view_name).should eql([Foo.new('_id' => 'bar')])
    end

  end
end
