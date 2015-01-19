require "spec_helper"

module EgaugeRuby
  describe Gauge do
    let(:current_xml) {
      <<-XML
      <?xml version="1.0" encoding="UTF-8" ?>
      <data serial="0x24658c9e">
       <ts>1421689501</ts>
       <gen>10575011</gen>
       <r t="P" n="Grid"><v>5422608379</v><i>462</i></r>
       <r t="P" n="PV Array 1"><v>10756227175</v><i>-6</i></r>
       <r t="P" n="PV Array 1+"><v>10921866253</v><i>0</i></r>
       <r t="P" n="PV  Array 2"><v>-281442840500341</v><i>-5</i></r>
       <r t="P" n="PV  Array 2+"><v>29400860389</v><i>0</i></r>
       <r t="P" n="Fans + Halls?"><v>5036795335</v><i>2</i></r>
       <r t="P" n="East front hall"><v>1808108522</v><i>9</i></r>
       <r t="P" n="West front hall"><v>579639683</v><i>1</i></r>
       <r t="P" n="Recept East"><v>31254539</v><i>0</i></r>
       <r t="P" n="Recept West"><v>238445485</v><i>0</i></r>
       <r t="P" n="12kBtu Air Conditioning"><v>2068949679</v><i>100</i></r>
       <r rt="total" t="P" n="Total Usage"><v>-281426661664787</v><i>451.000</i></r>
       <r rt="total" t="P" n="Total Generation"><v>-281432084273166</v><i>-11.000</i></r>
      </data>
      XML
    }

    let(:url) { "http://22north.egaug.es" }

    let!(:current_request) do
      request = EgaugeRuby::Request.new(
          base_url: url,
          query_arguments: ['tot', 'inst']
        )
      request.document = request.parse(current_xml)
      request.set_registers
      request
    end

    subject { EgaugeRuby::Gauge.new(url) }

    describe '#current' do
      it "returns a hash with name => power for each register" do
        subject.request = current_request
        results = subject.current
        expect(results["Grid"]).to eq(462)
        expect(results.count).to eq(13)
      end
    end
  end

  describe Request do

    # Need to:
    # 1. Use a canned XML document to test against
    # 2. Write high level API specs instead of low level
    # 3. Finish with high level HTTP requests using a lib ...
    # ... like VCR or Rspec Mocks

    let(:stored_xml) {
      <<-XML
      <?xml version="1.0" encoding="UTF-8" ?>
      <!DOCTYPE group PUBLIC "-//ESL/DTD eGauge 1.0//EN" "http://www.egauge.net/DTD/egauge-hist.dtd">
      <group serial="0x24658c9e">
      <data columns="11" time_stamp="0x54bd3810" time_delta="3600" epoch="0x4edbd230">
       <cname t="P">Grid</cname>
       <cname t="P">PV Array 1</cname>
       <cname t="P">PV Array 1+</cname>
       <cname t="P">PV  Array 2</cname>
       <cname t="P">PV  Array 2+</cname>
       <cname t="P">Fans + Halls?</cname>
       <cname t="P">East front hall</cname>
       <cname t="P">West front hall</cname>
       <cname t="P">Recept East</cname>
       <cname t="P">Recept West</cname>
       <cname t="P">12kBtu Air Conditioning</cname>
       <r><c>5421193561</c><c>10756242555</c><c>10921866253</c><c>-281442840478049</c><c>29400859770</c><c>5036790157</c><c>1808085281</c><c>579636989</c><c>31254526</c><c>238445467</c><c>2068764003</c></r>
       <r><c>5419369049</c><c>10756260672</c><c>10921866253</c><c>-281442840445734</c><c>29400859770</c><c>5036782824</c><c>1808054322</c><c>579633211</c><c>31254516</c><c>238445444</c><c>2068597390</c></r>
       <r><c>5417872932</c><c>10756272018</c><c>10921862673</c><c>-281442840430587</c><c>29400848011</c><c>5036775956</c><c>1808023286</c><c>579629785</c><c>31254506</c><c>238445417</c><c>2068310516</c></r>
      </data>
      </group>
      XML
    }

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
