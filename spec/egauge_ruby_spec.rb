require "spec_helper"

module EgaugeRuby
  describe Egauge do

    it "isn't nil when instantiated" do
      subject.nil?.should == false
    end

    it "#get_current returns a 200 HTTP code" do
      # p subject.get_current
      subject.get_current.code.should eq(200)
    end

    it "#get_current returns some XML" do
      # p subject.get_current
      subject.get_current.body.length.should be > 20
    end

    it '#parse turns XML into a ruby object' do
      response = subject.get_current
      doc = subject.parse(response)
      doc.should_not eq(nil)
    end
  end
end
