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

    describe '#current' do
      it "has a length > 1" do
        expect(doc.to_xml.length).to be > 1
      end
    end
  end
end
