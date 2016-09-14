require "rails_helper"

module OkComputer
  describe CacheCheck do

    let(:stats) do
      { "foo" => { "bytes" => "10000000", "limit_maxbytes" => "30000000" },
        "bar" => { "bytes" => "40000", "limit_maxbytes" => "900000" } }
    end

    it "is a Check" do
      subject.should be_a Check
    end

    context "new(host)" do
      it "remembers the host given to it" do
        subject = CacheCheck.new("example.com")
        expect(subject.host).to eq("example.com")
      end

      it "defaults to the machine's name" do
        subject = CacheCheck.new
        expect(subject.host).to eq(Socket.gethostname)
      end
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
          stub_const("Socket", Module.new)
          Socket.stub(:gethostname){ 'foo' }
          Rails.stub_chain(:cache, :stats){ stats }
        end

        it "should return a stats string" do
          subject.stats.should eq "9 / 28 MB, 1 peers"
        end
      end

      context "when cannot connect to cache" do
        before do
          Rails.stub_chain(:cache, :stats){ raise 'broken' }
        end

        it { expect{ subject.stats }.to raise_error(CacheCheck::ConnectionFailed) }
      end

      context "when using a cache without stats" do
        it 'use GenericCacheCheck' do
          generic_cache_check = double(GenericCacheCheck)
          expect(generic_cache_check).to receive(:check)
          expect(GenericCacheCheck).to receive(:new).and_return(generic_cache_check)
          subject.check
        end
      end
    end
  end
end
