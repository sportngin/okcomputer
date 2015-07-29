require "rails_helper"

module OkComputer
  describe HttpCheck do
    let(:url) { "http://localurl:9000" }

    subject { described_class.new(url) }

    it "is a subclass of Check" do
      subject.should be_a Check
    end

    describe "#new(url, request_timeout)" do
      it "requires url" do
        expect { described_class.new }.to raise_error
      end

      it "remembers url" do
        expect(subject.url).to eq(URI(url))
      end

      it "defaults request_timeout to 5 seconds" do
        expect(subject.request_timeout).to eq(5)
      end

      it "remembers request_timeout" do
        check = described_class.new(url, 10)
        expect(check.request_timeout).to eq(10)
      end

      it "coerces request_timeout to an integer" do
        check = described_class.new(url, "8")
        expect(check.request_timeout).to eq(8)
      end
    end

    describe "#check" do
      context "when the connection is successful" do
        before do
          subject.stub(:perform_request).and_return("foo")
        end

        it { should be_successful }
        it { should have_message "HTTP check successful" }
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

    describe "#perform_request" do
      context "when the connection is successful" do
        before do
          stub_request(:get, url).to_return(body: 'foo')
        end

        it "returns the response body" do
          expect(subject.perform_request).to eq("foo")
        end
      end

      context "when the connection fails" do
        let(:error_message) { "Error message" }

        before do
          stub_request(:get, url).to_raise(Errno::ENETUNREACH)
        end

        it "raises a ConnectionFailed error" do
          expect { subject.perform_request }.to raise_error(HttpCheck::ConnectionFailed)
        end
      end

      context "when the connection takes too long" do
        before do
          subject.request_timeout = 0.1
          stub_request(:get, url).with { sleep(subject.request_timeout + 0.1) }
        end

        it "raises a ConnectionFailed error" do
          expect { subject.perform_request }.to raise_error(HttpCheck::ConnectionFailed)
        end
      end
    end
  end
end
