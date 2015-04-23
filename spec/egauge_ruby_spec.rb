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

    let!(:fake_request) do
      request = EgaugeRuby::Request.new(base_url: url, query_arguments: ['tot', 'inst'])
      request.response = current_xml
      request
    end

    subject { EgaugeRuby::Gauge.new(url) }

    describe '#current' do
      it "returns a hash with name => power for each register" do
        subject.request = fake_request # mock out the request
        subject.data = Data.new(fake_request)
        results = subject.current
        expect(results["Grid"]).to eq(462)
        expect(results.count).to eq(13)
      end
    end

    describe '#stored' do
      let(:fake_stored) {
        <<-XML
        <?xml version="1.0" encoding="UTF-8" ?>
        <!DOCTYPE group PUBLIC "-//ESL/DTD eGauge 1.0//EN" "http://www.egauge.net/DTD/egauge-hist.dtd">
        <group serial="0x24658c9e">
        <data columns="11" time_stamp="0x54bd8c70" time_delta="3600" epoch="0x4edbd230">
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
         <r><c>5430750946</c><c>10756132228</c><c>10921869967</c><c>-281442840623218</c><c>29400865633</c><c>5036832069</c><c>1808270727</c><c>579659896</c><c>31254641</c><c>238445598</c><c>2070062510</c></r>
         <r><c>5429234588</c><c>10756151649</c><c>10921869967</c><c>-281442840607730</c><c>29400865633</c><c>5036825066</c><c>1808239954</c><c>579655680</c><c>31254616</c><c>238445579</c><c>2069880800</c></r>
         <r><c>5427592022</c><c>10756171604</c><c>10921869967</c><c>-281442840592215</c><c>29400865633</c><c>5036818058</c><c>1808208951</c><c>579651440</c><c>31254594</c><c>238445559</c><c>2069640867</c></r>
         <r><c>5426031496</c><c>10756190373</c><c>10921869967</c><c>-281442840552727</c><c>29400865633</c><c>5036810562</c><c>1808178167</c><c>579647564</c><c>31254575</c><c>238445536</c><c>2069473351</c></r>
         <r><c>5424454425</c><c>10756211778</c><c>10921869967</c><c>-281442840515716</c><c>29400865633</c><c>5036803600</c><c>1808147288</c><c>579643931</c><c>31254558</c><c>238445512</c><c>2069212300</c></r>
         <r><c>5422988527</c><c>10756221425</c><c>10921866253</c><c>-281442840502108</c><c>29400861766</c><c>5036796957</c><c>1808116284</c><c>579640510</c><c>31254543</c><c>238445491</c><c>2069005502</c></r>
         <r><c>5421193561</c><c>10756242555</c><c>10921866253</c><c>-281442840478049</c><c>29400859770</c><c>5036790157</c><c>1808085281</c><c>579636989</c><c>31254526</c><c>238445467</c><c>2068764003</c></r>
         <r><c>5419369049</c><c>10756260672</c><c>10921866253</c><c>-281442840445734</c><c>29400859770</c><c>5036782824</c><c>1808054322</c><c>579633211</c><c>31254516</c><c>238445444</c><c>2068597390</c></r>
         <r><c>5417872932</c><c>10756272018</c><c>10921862673</c><c>-281442840430587</c><c>29400848011</c><c>5036775956</c><c>1808023286</c><c>579629785</c><c>31254506</c><c>238445417</c><c>2068310516</c></r>
         <r><c>5416945524</c><c>10756286561</c><c>10921860937</c><c>-281442840408419</c><c>29400839589</c><c>5036768223</c><c>1808021509</c><c>579625887</c><c>31254499</c><c>238445385</c><c>2068141976</c></r>
         <r><c>5415955039</c><c>10756296363</c><c>10921852772</c><c>-281442840368095</c><c>29400832145</c><c>5036760538</c><c>1808020748</c><c>579621951</c><c>31254485</c><c>238445358</c><c>2067913462</c></r>
         <r><c>5414863227</c><c>10756316676</c><c>10921852772</c><c>-281442840351859</c><c>29400832145</c><c>5036752911</c><c>1808020069</c><c>579618015</c><c>31254467</c><c>238445335</c><c>2067728889</c></r>
         <r><c>5413517093</c><c>10756338165</c><c>10921852772</c><c>-281442840335546</c><c>29400832145</c><c>5036745574</c><c>1808019441</c><c>579614184</c><c>31254447</c><c>238445321</c><c>2067480597</c></r>
         <r><c>5412099081</c><c>10756359953</c><c>10921852772</c><c>-281442840319373</c><c>29400832145</c><c>5036738534</c><c>1808018542</c><c>579609828</c><c>31254423</c><c>238445306</c><c>2067329072</c></r>
         <r><c>5410920906</c><c>10756381622</c><c>10921852772</c><c>-281442840303028</c><c>29400832145</c><c>5036731084</c><c>1808017966</c><c>579605921</c><c>31254401</c><c>238445287</c><c>2067102616</c></r>
         <r><c>5409855735</c><c>10756402827</c><c>10921852772</c><c>-281442840286767</c><c>29400832145</c><c>5036723448</c><c>1808017403</c><c>579601942</c><c>31254378</c><c>238445273</c><c>2066958239</c></r>
         <r><c>5408712671</c><c>10756424931</c><c>10921852772</c><c>-281442840270373</c><c>29400832145</c><c>5036715996</c><c>1808016824</c><c>579597999</c><c>31254357</c><c>238445255</c><c>2066731334</c></r>
         <r><c>5407654153</c><c>10756446269</c><c>10921852772</c><c>-281442840254122</c><c>29400832145</c><c>5036708319</c><c>1808016255</c><c>579593991</c><c>31254338</c><c>238445239</c><c>2066594191</c></r>
         <r><c>5406495662</c><c>10756468608</c><c>10921852772</c><c>-281442840237668</c><c>29400832145</c><c>5036700931</c><c>1808015659</c><c>579590054</c><c>31254319</c><c>238445223</c><c>2066355079</c></r>
         <r><c>5405429489</c><c>10756489875</c><c>10921852772</c><c>-281442840221395</c><c>29400832145</c><c>5036693368</c><c>1808015083</c><c>579586039</c><c>31254299</c><c>238445206</c><c>2066212371</c></r>
         <r><c>5404282518</c><c>10756511730</c><c>10921852772</c><c>-281442840204939</c><c>29400832145</c><c>5036686006</c><c>1808014499</c><c>579582094</c><c>31254280</c><c>238445188</c><c>2065981959</c></r>
         <r><c>5403225895</c><c>10756532683</c><c>10921852772</c><c>-281442840188667</c><c>29400832145</c><c>5036678472</c><c>1808013930</c><c>579578104</c><c>31254261</c><c>238445170</c><c>2065846784</c></r>
         <r><c>5402088568</c><c>10756554035</c><c>10921852772</c><c>-281442840172289</c><c>29400832145</c><c>5036671170</c><c>1808013347</c><c>579574207</c><c>31254241</c><c>238445154</c><c>2065625899</c></r>
         <r><c>5401035954</c><c>10756574659</c><c>10921852772</c><c>-281442840156061</c><c>29400832145</c><c>5036663673</c><c>1808012783</c><c>579570250</c><c>31254219</c><c>238445137</c><c>2065494560</c></r>
         <r><c>5399900902</c><c>10756596178</c><c>10921852772</c><c>-281442840139710</c><c>29400832145</c><c>5036656369</c><c>1808012200</c><c>579566349</c><c>31254197</c><c>238445121</c><c>2065274764</c></r>
        </data>
        </group>
        XML
      }
      let!(:fake_request) do
        request = EgaugeRuby::Request.new(base_url: url, type: "stored", query_arguments: ['h', 'n=24'])
        request.response = fake_stored
        request
      end

      before do
        subject.request = fake_request
        subject.data = Data.new(fake_request)
      end

      it "creates N registers for each row R, excluding the first row (N * R -1)" do
        expect(subject.data.registers.count).to eq(264)
      end

      it "returns past register values given start and end time strings" do
        expected_results = { name: "Grid",
                             timestamp: "2015-01-19 17:00:00 -0500",
                             interval: 3600,
                             type: "P",
                             value: 5429234588,
                             instantaneous: 421,}

        register_hash =
          subject.stored("2015-01-19 18:00:00 -0500", "2015-01-18 18:00:00 -0500", :hours)["Grid"].first.to_hash

        expect(register_hash).to include(expected_results)
      end
    end

    describe '#url' do
      it 'has a url and it is valid' do
        expect(subject.url).to eq("http://22north.egaug.es")
      end
    end

    describe '#request' do
      it 'has a request object' do
        expect(subject.request).to_not be(nil)
        expect(subject.request.class).to eq(EgaugeRuby::Request)
      end
    end

    describe '#data' do
      it 'has a data object' do
        expect(subject.data).to_not be(nil)
        expect(subject.data.class).to eq(EgaugeRuby::Data)
      end
    end
  end

  describe Data do
    describe '#registers' do
    end

    describe '#document' do
    end

    describe '#timestamp' do
    end

    describe '#interval' do
    end

    describe '#request' do
    end
  end

  describe Register do
    describe '#timestamp' do
    end

    describe '#interval' do
    end

    describe '#name' do
    end

    describe '#type' do
    end

    describe '#value' do
    end

    describe '#instantaneous' do
    end

    describe '#to_hash' do
    end

    describe '#calc_instantaneous' do
    end

    describe '#power' do
    end

    describe '#to_json' do
      # some test
    end
  end


  describe Request do

    let(:url) { "http://22north.egaug.es" }
    let(:query_args) { ['v1', 'tot', 'inst'] }
    subject { EgaugeRuby::Request.new(base_url: url, query_arguments: query_args) }
    let(:response) {subject.get_xml }

    it "isn't nil when instantiated" do
      expect(subject.nil?).to eq(false)
    end

    describe "API arguments" do
      it "can request current measurements or historical"

      it "can specify whether to include totals"

      it "can request instantaneous values (power)"
    end

    describe '#get_xml' do

      it "returns a 200 HTTP code" do
        expect(subject.get_xml.code).to eq(200)
      end

      it "returns some XML" do
        expect(subject.get_xml.body.length).to be > 20
      end

      describe "with a stored request" do
        let(:type) { "stored" }
        subject { EgaugeRuby::Request.new(base_url: url, type: type) }

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
  end
end
