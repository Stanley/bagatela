require File.join(File.dirname(__FILE__), '..', '..', '..', 'spec_helper')
include Bagatela::Graph

describe Search::Fast do

  it "should find the fastest connection between two stops" do

    # Given the following graph:
    # 0_____1
    # .\....|
    # ..2...|
    # ..|\..|
    # ..\.3.|
    # ...\.\|
    # ....4_5
    
    hub = []

    Neo4j::Transaction.run do

      hub = [
        Hub.new(:name => 'Hub0', :lat => 0.00, :lon => 0.00),
        Hub.new(:name => 'Hub1', :lat => 0.06, :lon => 0.00),
        Hub.new(:name => 'Hub2', :lat => 0.02, :lon => 0.02),
        Hub.new(:name => 'Hub3', :lat => 0.04, :lon => 0.04),
        Hub.new(:name => 'Hub4', :lat => 0.04, :lon => 0.06),
        Hub.new(:name => 'Hub5', :lat => 0.06, :lon => 0.06)
      ]

      connection = []

      connection[0] = Connection.new(:connects, hub[0], hub[1])
      connection[0].rides = {
        12*60     => {:duration => 3}, # departures at 12:00 and arrives three minute later
        12*60 + 3 => {:duration => 3}, #               12:03
        12*60 + 5 => {:duration => 3}  #               12:05
      }

      connection[1] = Connection.new(:connects, hub[0], hub[2])
      connection[1].rides = {
        12*60 + 1 => {:duration => 1}, # departures at 12:01 and arrives one minute later
        12*60 + 4 => {:duration => 1}, #               12:04
        12*60 + 7 => {:duration => 1}  #               12:07
      }

      connection[2] = Connection.new(:connects, hub[1], hub[5])
      connection[2].rides = {
        12*60 + 0 => {:duration => 3}, # departures at 12:00 and arrives three minutes later
        12*60 + 5 => {:duration => 3}, #               12:05
        12*60 +10 => {:duration => 3}  #               12:07
      }

      connection[3] = Connection.new(:connects, hub[2], hub[3])
      connection[3].rides = {
        12*60 + 6 => {:duration => 2}, #               12:06
        12*60 + 9 => {:duration => 2}  #               12:09
      }

      connection[4] = Connection.new(:connects, hub[2], hub[4])
      connection[4].rides = {
        12*60 + 3 => {:duration => 2} # departures at 12:03 and arrives two minutes later
      }

      connection[5] = Connection.new(:connects, hub[3], hub[5])
      connection[5].rides = {
        12*60 + 8 => {:duration => 2}, # departures at 12:08 and arrives two minutes later
        12*60 +11 => {:duration => 2}  #               12:11
      }

      connection[6] = Connection.new(:connects, hub[4], hub[5])
      connection[6].rides = {
        12*60 + 5 => {:duration => 2}  # departures at 12:05 and arrives two minutes later
      }

    end

    time = Time.parse('12:00')
    journey = Search::Fast.journey(from: hub[0], to: hub[5], time: time)

    #journey.departure.should eql(Time.parse('12:01'))
    journey.arrival.should   eql(Time.parse('12:07'))
  end
end
