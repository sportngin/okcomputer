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
        it { should have_message "Successfully connected to mongodb #{mongodb_name}" }
      end

      context "with an unsuccessful connection" do
        before do
          subject.should_receive(:mongodb_name).and_raise(MongoidCheck::ConnectionFailed, error_message)
        end

        it {should_not be_successful }
        it {should have_message "Failed to connect: '#{error_message}'" }
      end
    end

    context "#mongodb_name" do
      it "returns the name of the mongodb" do
        subject.should_receive(:mongodb_stats) { stats }
        subject.mongodb_name.should == stats["db"]
      end
    end

    context "#mongodb_stats" do
      let(:database) { stub(:database) }

      it "returns a mongodb stats hash" do
        database.should_receive(:stats) { stats }
        Mongoid.should_receive(:database) { database }
        subject.mongodb_stats.should == stats
      end
    end
  end
end
