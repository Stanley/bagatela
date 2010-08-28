require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'main application' do
  include Rack::Test::Methods

  def app
    Bagatela.new
  end

  it "should have specs" do
    pending
  end
end
