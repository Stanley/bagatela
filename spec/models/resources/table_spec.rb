require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

include Bagatela::Resources

describe Table do

  describe "basics" do
    subject{ Table.new "12"=>["00","15"] }

    it "should enumerate over departures" do
      subject.to_a.should eql([720,735])
    end

    it "should find next departure" do
      min = 12*60 + 11 # 12:11
      subject.after(min).should eql(12*60 + 15) # 12:15
    end

    it "should return departures count before given time" do
      subject.index_before(12*60 + 7).should eql(1)
    end

    it "should return departures count before given time + 1" do
      subject.index_after(12*60).should eql(1)
    end
  end

  describe "connection" do

    it "should calculate trip time" do
      run = Table.new('12'=>['05']).departures(Table.new('12'=>['07']))[12*60+5]
      run['duration'].should eql(2)
    end

    it "should include line numbers" do
      params = {'tables'=>{'*'=>{'12'=>['00']}},'line'=>'L'}
      run = Timetable.new(params).
        table(Time.now).departures[12*60]
      run['line'].should eql('L')
    end
  end

  describe "connection with extra departures added" do

    before do
      @departures = Table.new( '12'=>['05'] ).
        departures( Table.new( '12'=>['08'], '13'=>['08'] ))
    end

    it "should not include runs which don't stop on both nodes" do
      @departures.should have(1).item
    end

    it "should assume the shortest departures" do
      @departures[12*60+5]['duration'].should eql(3)
    end

  end

  describe "connection with node on which some runs end" do

    before do
      @departures = Table.new('12'=>['06'],'13'=>['06']).
        departures( Table.new('12'=>['09']))
    end

    it "should couple departures with next in time arrival" do
      @departures[12*60+6]['duration'].should eql(3)
    end

    it "should estimate arrival time of ending runs" do
      @departures[13*60+6]['prediction'].should be_true
    end

  end

  describe "false connection" do

    it "should be detected if it both loses and gains runs" do
      departures = Table.new('12'=>['07','27']).
        departures(Table.new('12'=>['09','19']))

      departures.should be_nil
    end

    it "should be detected if there are two runs at the same time" do
      departures = Table.new('12'=>['07','12']).
        departures(Table.new('12'=>['17','20']))

      departures.should be_nil
    end

    #it "should be detected if runs' ending colides with another run" do
      #departures = Table.new('12'=>['07','12']).
        #departures(Table.new('12'=>['17']))

      #departures.should be_nil
    #end

    it "should be detected if first runs don't match" do
      departures = Table.new('12'=>['10','30']).
        departures(Table.new('12'=>['00','20']))

      departures.should be_nil
    end

    it "should be detected if first arrival goes before first deparute" do
      departures = Table.new('12'=>['10','30']).
        departures(Table.new('12'=>['00']))

      departures.should be_nil

      # TODO move
      departures = Table.new('12'=>['00','05','10']).
        departures(Table.new('12'=>['08']))

      departures.should_not be_nil
    end


    it "should be detected if last departure goes after last arrival" do
      departures = Table.new('12'=>['30']).
        departures(Table.new('12'=>['00','20']))

      departures.should be_nil

      departures = Table.new('12'=>['10']).
        departures(Table.new('12'=>['00','13','20']))

      departures.should_not be_nil
    end

    it "should .. if last departure goes with first first arrival" do
      departures = Table.new('0'=>['25'],'1'=>['25'],'2'=>['25']).
        departures(Table.new('23'=>['49'],'0'=>['49'],'1'=>['49']))

      departures.should be_nil

      departures = Table.new('23'=>['53'],'1'=>['06'],'2'=>['06']).
        departures(Table.new('0'=>['00'],'1'=>['10'],'2'=>['10']))

      departures.should_not be_nil
    end
  end

  describe "arrival time to terminus" do
    before do
      @departures = Table.new('12'=>['00','30']).departures
    end

    it "should be estimated" do
      @departures.should have(2).items
    end
  end

  describe "time borders" do

    it "should have first run of the day" do
      table = Table.new('8'=>['00'], '10'=>['00'])
      
      table.first.should eql(8*60)
      table.last.should eql(10*60)
    end

    it "should have first run of the night" do
      table = Table.new('23'=>['00'], '1'=>['00'])
      
      table.first.should eql(23*60)
      table.last.should eql(1*60)
    end

  end

  # Rare and unfortunate case. Eg.: ...
  describe "two identical" do
    it "should be connected with zero trip time" do
      departures = Table.new('0'=>['00'],'1'=>['00'],'2'=>['00']).
        departures(Table.new('0'=>['00'],'1'=>['00'],'2'=>['00']))

      departures.should_not be_nil
      departures.inject(0){|sum,(key,val)| sum+val['duration'] }.should eql(0)
    end
  end
end
