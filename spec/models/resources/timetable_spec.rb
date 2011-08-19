require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')
require 'rspec/mocks/standalone'

include Bagatela::Resources

describe Timetable do
  describe "destination" do

    it "should be extracted from route and upcased" do
      timetable = Timetable.new({'route' => 'FOO BAR - foobar, barfoo - BAR FOO'})
      timetable.destination.should eql('BAR FOO')
    end

  end
  describe "rides" do
    before :all do
      @rides = Timetable.new({'tables'=>{'*'=>{'12'=>['05']}}, 'line'=>'L'}).
        rides( Time.now, Timetable.new({'tables'=>{'*'=>{'12'=>['07']}}}) )
    end

    it "should convert time to minutes from midnight" do
      @rides.keys.should eql([12*60+5])
    end

    it "should calculate trip time" do
      @rides[12*60+5]['duration'].should eql(2)
    end

    it "should include line numbers" do
      @rides[12*60+5]['line'].should eql('L')
    end

  end
  describe "the last stop" do
    # 1 minute by default. TODO: make it smarter

    it "should estimate trip time of the last section" do
      params = {'tables' => {'*' => {'12' => ['00']}}}
      ride = Timetable.new(params).rides(Time.now)[12*60]
      ride['duration'].should eql(1)
    end

    it "should estimate trip time on the shortened route" do
      params = {'tables' => {'*' => {'12' => ['00']}}}
      ride = Timetable.new(params).rides(Time.now, Timetable.new({}))[12*60]
      ride['duration'].should eql(1)
    end

  end
  describe "single table" do

    let(:weekday){}

    #it "should be 'Dni Powszednie' any weekday" do
      #departures = {"12" => ["00"]}
      #table = Timetable.new().table(weekday)
      #table.should eql(Table.new(departures))
    #end

  end
end
