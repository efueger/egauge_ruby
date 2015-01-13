require "spec_helper"

module EgaugeRuby
  describe Egauge do

    let(:url) { "http://22north.egaug.es/cgi-bin/egauge" }
    subject { EgaugeRuby::Egauge.new(url) }
    let(:response) {subject.get_current }

    it "isn't nil when instantiated" do
      expect(subject.nil?).to eq(false)
    end

    describe '#get_current' do

      it "returns a 200 HTTP code" do
        expect(subject.get_current.code).to eq(200)
      end

      it "returns some XML" do
        expect(subject.get_current.body.length).to be > 20
      end
    end

    let(:doc) {subject.current}

    describe '#parse' do
      it '#parse turns XML into Ruby objects' do
        expect(subject.parse(response).class).to eq(Nokogiri::XML::Document)
      end
    end

    describe "#registers" do
      it "returns an array of the registers associated with the request"
    end

    describe '#current' do
      it "returns a hash of register(s) attributes"
      it "filters values based on an optional filter hash argument"
    end

    describe "#last_day" do
      it "gets values for the last day(24 hours)"
      it "returns a hash of the average value for each register"
    end

    describe "updates all attributes on request response" do
      it "uses the response to update all attributes"
      it "clears the old registers"
      it "creates new registers for new response data"
    end
  end
end
