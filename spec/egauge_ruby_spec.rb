require "spec_helper"

module EgaugeRuby
  describe Egauge do

    it "isn't nil when instantiated" do
      subject.nil?.should == false
    end

    it "can say #hi" do
      subject.hi.should == "It works"
    end
  end
end
