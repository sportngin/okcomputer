module OkComputer
  describe ElasticsearchCheck do
    let(:host) { "http://localhost:9200" }

    subject { described_class.new(host) }

    it "is a subclass of Check" do
      subject.should be_a Check
    end

    describe "#new(host, request_timeout)" do
      it "requires host" do
        expect { described_class.new }.to raise_error
      end

      it "saves host as a URI and sets url to cluster health API url" do
        expect(subject.host).to eq URI(host)
        expect(subject.url).to eq(URI("#{host}/_cluster/health"))
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
        before do
          subject.stub(:cluster_health).and_return(cluster_health)
        end

        context "when the cluster is healthy" do
          let(:cluster_health) do
            {
              cluster_name: "elasticsearch",
              status: "yellow",
              number_of_nodes: 1
            }
          end

          it { should be_successful }
          it { should have_message "Connected to elasticseach cluster 'elasticsearch', 1 nodes, status 'yellow'" }
        end

        context "when the cluster is unhealthy" do
          let(:cluster_health) do
            {
              cluster_name: "elasticsearch",
              status: "red",
              number_of_nodes: 1
            }
          end

          it { should_not be_successful }
          it { should have_message "Connected to elasticseach cluster 'elasticsearch', 1 nodes, status 'red'" }
        end
      end

      context "when the connection fails" do
        let(:error_message) { "Error message" }

        before do
          subject.stub(:cluster_health).and_raise(HttpCheck::ConnectionFailed, error_message)
        end

        it { should_not be_successful }
        it { should have_message "Error: '#{error_message}'" }
      end
    end

    describe "#cluster_health" do
      context "when the connection is successful" do
        let(:cluster_health) do
          {
            cluster_name: "elasticsearch",
            status: "green",
            number_of_nodes: 2
          }
        end

        let(:response) { cluster_health.to_json }

        before do
          subject.stub(:perform_request).and_return(response)
        end

        it "returns a symbolized hash of the cluster health API response" do
          expect(subject.cluster_health).to eq(cluster_health)
        end
      end

      context "when the connection fails" do
        before do
          subject.stub(:perform_request).and_raise(HttpCheck::ConnectionFailed)
        end

        it "raises a ConnectionFailed error" do
          expect { subject.cluster_health }.to raise_error(HttpCheck::ConnectionFailed)
        end
      end
    end
  end
end
