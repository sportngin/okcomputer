require "spec_helper"

# Stubbing the constant out; will exist in apps which have Resque loaded
class Resque; end

module OKComputer
  describe ResqueDownCheck do
    let(:queue) { "queue name" }

    subject { ResqueDownCheck.new queue }

    it "is a Check" do
      subject.should be_a Check
    end

    context ".new(queue)" do
      it "accepts a queue name to check whether any jobs are in the queue" do
        subject.queue.should == queue
      end
    end

    context "#call" do
      it "returns a success message if no jobs are queued" do
        subject.stub(:queued?) { false }
        subject.should_not_receive(:mark_failure)
        subject.call.should include "Resque is working"
      end

      context "with queued jobs" do
        before do
          subject.stub(:queued?) { true }
        end

        it "returns a success message if workers are working" do
          subject.stub(:working?) { true }
          subject.should_not_receive(:mark_failure)
          subject.call.should include "Resque is working"
        end

        it "returns a failure message if workers are not working" do
          subject.stub(:working?) { false }
          subject.should_receive(:mark_failure)
          subject.call.should include "Resque is DOWN"
        end
      end
    end

    context "#queued?" do
      it "is true if Resque says the queue has jobs" do
        Resque.should_receive(:info) { {pending: 1} }
        subject.should be_queued
      end

      it "is false if Resque says the queue has no jobs" do
        Resque.should_receive(:info) { {pending: 0} }
        subject.should_not be_queued
      end
    end

    context "#working?" do
      it "is true if Resque says it has workers working" do
        Resque.should_receive(:info) { {working: 1} }
        subject.should be_working
      end

      it "is false if Resque says its jobs are not working" do
        Resque.should_receive(:info) { {working: 0} }
        subject.should_not be_working
      end
    end
  end
end
