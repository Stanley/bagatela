require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

include Bagatela::Data

describe Table do
  subject{ Table.new "12"=>["00","15"] }

  it "should enumerate over departures" do
    subject.to_a.should eql([720,735])
  end

  it "should find next departure" do
    min = 12*60 + 11 # 12:11
    subject.after(min).should eql(12*60 + 15) # 12:15
  end

end
