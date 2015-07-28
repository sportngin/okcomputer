module OkComputer
  describe SolrCheck do
    let(:host) { "http://localhost:8982/solr" }

    subject { described_class.new(host) }

    it "is a subclass of Check" do
      subject.should be_a Check
    end

    describe "#new(host, request_timeout)" do
      it "requires host" do
        expect { described_class.new }.to raise_error
      end

      it "saves host as a URI and sets url to the ping handler" do
        expect(subject.host).to eq(URI(host))
        expect(subject.url).to eq(URI("#{host}/admin/ping"))
      end

      it "defaults request_timeout to 5 seconds" do
        expect(subject.request_timeout).to eq(5)
      end

      it "remembers request_timeout" do
        check = described_class.new(host, 10)
        expect(check.request_timeout).to eq(10)
      end
    end

    describe "#check" do
      context "when the connection is successful" do
        context "when the status is OK" do
          before do
            subject.stub(:ping?).and_return(true)
          end

          it { should be_successful }
          it { should have_message "Solr ping reported success" }
        end

        context "when the status is not OK" do
          before do
            subject.stub(:ping?).and_return(false)
          end

          it { should_not be_successful }
          it { should have_message "Solr ping reported failure" }
        end
      end

      context "when the connection fails" do
        let(:error_message) { "Error message" }

        before do
          subject.stub(:perform_request).and_raise(HttpCheck::ConnectionFailed, error_message)
        end

        it { should_not be_successful }
        it { should have_message "Error: '#{error_message}'" }
      end
    end

    describe "#ping?" do
      context "when the connection is successful" do
        before do
          subject.stub(:perform_request).and_return(response)
        end

        context "when the status is OK" do
          let(:response) do
            %q(
                <?xml version="1.0" ?>
                <response>
                    <lst name="responseHeader">
                        <int name="status">0</int>
                        <int name="QTime">2</int>
                        <lst name="params">
                            <str name="echoParams">all</str>
                            <str name="q">solrpingquery</str>
                            <str name="qt">standard</str>
                            <str name="echoParams">all</str>
                        </lst>
                    </lst>
                    <str name="status">OK</str>
                </response>
            )
          end

          it "returns true" do
            expect(subject.ping?).to be true
          end
        end

        context "when the status is not OK" do
          let(:response) { "500" }

          it "returns false" do
            expect(subject.ping?).to be false
          end
        end
      end

      context "when the connection fails" do
        before do
          subject.stub(:perform_request).and_raise(HttpCheck::ConnectionFailed)
        end

        it "raises a ConnectionFailed error" do
          expect { subject.ping? }.to raise_error(HttpCheck::ConnectionFailed)
        end
      end
    end
  end
end
