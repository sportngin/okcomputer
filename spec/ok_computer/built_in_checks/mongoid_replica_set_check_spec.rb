# Stubbing the constant out; will exist in apps which have Mongoid loaded
module Mongoid
  module Sessions
  end
end

module OkComputer
  describe MongoidReplicaSetCheck do

    let(:replica_set_name) { "foo" }
    let(:primary_status) { { "set" => replica_set_name, "myState" => 1 } }
    let(:secondary_status) { { "set" => replica_set_name, "myState" => 2 } }
    let(:session) { double('session') }
    let(:cluster) { double('cluster') }
    let(:primary_node) { double('primary') }
    let(:secondary_node) { double('secondary') }
    let(:nodes) { [primary_node, secondary_node, double('secondary')]}

    before do
      Mongoid::Sessions.stub(:with_name).and_return(session)
      session.stub(:cluster).and_return(cluster)

      cluster.stub(:refresh)
      cluster.stub(:nodes).and_return(nodes)
      cluster.stub(:with_primary).and_yield(primary_node)
      cluster.stub(:with_secondary).and_yield(secondary_node)

      primary_node.stub(:command).and_return(primary_status)
      secondary_node.stub(:command).and_return(secondary_status)
    end

    it "is a Check" do
      subject.should be_a Check
    end

    describe "#initialize" do
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
      let(:error_message) { "Error message" }

      context "with a successful connection" do
        before do
          cluster.should_receive(:refresh)
          subject.should_receive(:primary_status) { primary_status }
        end

        it { should be_successful }
        it { should have_message "Connected to 3 nodes in mongodb replica set '#{replica_set_name}'" }
      end

      context "with an unsuccessful connection" do
        before do
          subject.should_receive(:primary_status) { primary_status }
          subject.should_receive(:secondary_status).and_raise(MongoidReplicaSetCheck::ConnectionFailed, error_message)
        end

        it {should_not be_successful }
        it {should have_message "Error: '#{error_message}'" }
      end
    end

    describe "#primary_status" do
      it "returns primary node's mongodb replica set status hash" do
        expect(primary_node).to receive(:command).with(:admin, replSetGetStatus: 1).and_return(primary_status)
        expect(subject.primary_status).to eq(primary_status)
      end
    end

    describe "#secondary_status" do
      it "returns a secondary node's mongodb replica set status hash" do
        expect(secondary_node).to receive(:command).with(:admin, replSetGetStatus: 1).and_return(secondary_status)
        expect(subject.secondary_status).to eq(secondary_status)
      end
    end
  end
end
