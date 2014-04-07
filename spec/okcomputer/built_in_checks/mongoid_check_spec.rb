require "spec_helper"

# Stubbing the constant out; will exist in apps which have Mongoid loaded
class Mongoid; end

module OKComputer
  describe MongoidCheck do

    let(:stats) { { "db" => "foobar" } }

    it "is a Check" do
      subject.should be_a Check
    end

    context "#check" do
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

    context "#mongodb_name" do
      it "returns the name of the mongodb" do
        subject.should_receive(:mongodb_stats) { stats }
        subject.mongodb_name.should == stats["db"]
      end
    end

    context "#mongodb_stats" do

      context "Mongoid 3" do

        let(:default_session) { double(:default_session) }

        it "returns a mongodb stats hash" do
          default_session.should_receive(:command).with(dbStats: 1) { stats }
          Mongoid.should_receive(:default_session).with(no_args) { default_session }
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
