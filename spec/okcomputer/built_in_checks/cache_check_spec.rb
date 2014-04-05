require "spec_helper"

module OKComputer
  describe CacheCheck do

    let(:stats) { { "bytes" => "10000000", "limit_maxbytes" => "30000000" } }

    it "is a Check" do
      subject.should be_a Check
    end

    context "#check" do
      let(:stats) { "foo" }
      let(:error_message) { "Error message" }

      context "with a successful connection" do
        before do
          subject.should_receive(:stats) { stats }
        end

        it { should be_successful }
        it { should have_message "Cache is available (#{stats})" }
      end

      context "with an unsuccessful connection" do
        before do
          subject.should_receive(:stats).and_raise(CacheCheck::ConnectionFailed, error_message)
        end

        it {should_not be_successful }
        it {should have_message "Error: '#{error_message}'" }
      end
    end

    context "#stats" do

      context "when can connect to cache" do
        before do
          Rails.stub_chain(:cache, :stats){ stats }
        end

        it "should return a stats string" do
          subject.stats.should eq "9 / 28 MB"
        end
      end

      context "when cannot connect to cache" do

        it { expect{ subject.stats }.to raise_error }
      end
    end
  end
end
