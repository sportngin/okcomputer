# Stubbing the constant out; will exist in apps which have Mongoid loaded
module Mongoid
  module Sessions
  end
end

module OkComputer
  describe MongoidCheck do

    let(:stats) { { "db" => "foobar" } }
    let(:session) { double(:session) }

    it "is a Check" do
      subject.should be_a Check
    end

    describe "#initialize" do
      before do
        Mongoid.stub(:sessions)
      end

      it "uses the default session by default" do
        expect(Mongoid::Sessions).to receive(:with_name).with(:default).and_return(session)
        expect(subject.session).to eq(session)
      end

      it "accepts a session name" do
        other_session = double("other session")
        expect(Mongoid::Sessions).to receive(:with_name).with(:other_session).and_return(other_session)
        check = described_class.new(:other_session)
        expect(check.session).to eq(other_session)
      end
    end

    describe "#check" do
      let(:mongodb_name) { "foo" }
      let(:error_message) { "Error message" }

      context "with a successful connection" do
        before do
          subject.should_receive(:mongodb_name) { mongodb_name }
        end

        it { should be_successful }
        it { should have_message "Connected to mongodb #{mongodb_name}" }
      end

      context "with an unsuccessful connection" do
        before do
          subject.should_receive(:mongodb_name).and_raise(MongoidCheck::ConnectionFailed, error_message)
        end

        it {should_not be_successful }
        it {should have_message "Error: '#{error_message}'" }
      end
    end

    describe "#mongodb_name" do
      it "returns the name of the mongodb" do
        subject.should_receive(:mongodb_stats) { stats }
        subject.mongodb_name.should == stats["db"]
      end
    end

    describe "#mongodb_stats" do

      context "Mongoid 3" do

        before do
          Mongoid.stub(:sessions)
        end

        it "returns a mongodb stats hash" do
          session.should_receive(:command).with(dbStats: 1) { stats }
          Mongoid::Sessions.should_receive(:with_name).with(:default) { session }
          subject.mongodb_stats.should == stats
        end
      end

      context "Mongoid 2" do

        let(:database) { double(:database) }

        it "returns a mongodb stats hash" do
          database.should_receive(:stats) { stats }
          Mongoid.should_receive(:database) { database }
          subject.mongodb_stats.should == stats
        end
      end
    end
  end
end
