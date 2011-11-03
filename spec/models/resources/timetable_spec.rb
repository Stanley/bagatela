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

  describe "the last stop" do
    # 1 minute by default. TODO: make it smarter

    it "should estimate trip time of the last section" do
      params = {'tables' => {'*' => {'12' => ['00']}}}
      run = Timetable.new(params).
        table(Time.now).departures[12*60]
      run['duration'].should eql(1)
    end

    it "should estimate trip time on the shortened route" do
      params = {'tables' => {'*' => {'12' => ['00']}}}
      run = Timetable.new(params).
        table(Time.now).departures(Timetable.new({}))[12*60]
      run['duration'].should eql(1)
    end

  end

  describe "departures" do
    it "should include line number" do
      params = {'tables'=>{'*'=>{'12'=>['00']}},'line'=>'L'}
      departures = Timetable.new(params).departures

      departures[12*60]['line'].should eql('L')
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
