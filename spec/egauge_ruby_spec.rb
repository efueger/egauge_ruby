require "spec_helper"

module EgaugeRuby
  describe Request do

    let(:url) { "http://22north.egaug.es/cgi-bin/egauge" }
    let(:query_args) { ['v1', 'tot', 'inst'] }
    subject { EgaugeRuby::Request.new(base_url: url, query_arguments: query_args) }
    let(:response) {subject.get_xml }

    it "isn't nil when instantiated" do
      expect(subject.nil?).to eq(false)
    end

    describe "API arguments" do
      it "can request current measurements or historical"

      it "can specify the API version 1" do
        data_element = subject.document.xpath('//data')

        expect(data_element.class).to eq(Nokogiri::XML::NodeSet)
        expect(data_element.children.length).to be >= 1
      end

      it "can specify whether to include totals" do
        total_element = subject.document.xpath('//r[@rt="total"]').first

        expect(total_element.attributes['rt'].value).to eq('total')
      end

      it "can request instantaneous values (power)" do
        inst_element = subject.document.xpath('//r/i').first

        expect(inst_element.name).to  eq('i')
      end
    end

    describe '#get_xml' do

      it "returns a 200 HTTP code" do
        expect(subject.get_xml.code).to eq(200)
      end

      it "returns some XML" do
        expect(subject.get_xml.body.length).to be > 20
      end
      describe "with a current request" do
      end

      describe "with a stored request" do
        let(:type) { "stored" }
        subject { EgaugeRuby::Request.new(base_url: url, request_type: type) }

        it "has a request URL containing 'egauge-show'" do
          expect(subject.full_url).to include("egauge-show")
        end

        it "returns a 200 HTTP code" do
          expect(subject.get_xml.code).to eq(200)
        end

        it "returns some XML" do
          expect(subject.get_xml.body.length).to be > 20
        end
      end
    end

    describe '#parse' do
      it '#parse turns XML into Ruby objects' do
        expect(subject.parse(response).class).to eq(Nokogiri::XML::Document)
      end
    end

    describe "#registers" do
      it "returns an array of the registers associated with the request"
      it "has a unit attribute corresponding to the regiister type"
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

  describe Register do
    it "is instantiated to a non-nil value"
    it "has a nil value for empty instance attributes"
    it "has attributes equal to the xml values passed in"
    it "has a timestamp equal to the register that created it"
    it "has a unit attribute corresponding to the regiister type"
  end
end
