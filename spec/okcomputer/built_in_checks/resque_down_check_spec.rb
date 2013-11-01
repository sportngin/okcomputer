require "spec_helper"

# Stubbing the constant out; will exist in apps which have Resque loaded
class Resque; end

module OKComputer
  describe ResqueDownCheck do
    it "is a Check" do
      subject.should be_a Check
    end

    context "#check" do
      context "when not queued" do
        before do
          subject.stub(:queued?) { false }
        end

        it { should be_successful }
        it { should have_message "Resque is working" }
      end

      context "when queued" do
        before do
          subject.stub(:queued?) { true }
        end

        context "with workers working" do
          before do
            subject.stub(:working?) { true }
          end

          it { should be_successful }
          it { should have_message "Resque is working" }
        end

        context "with workers not working" do
          before do
            subject.stub(:working?) { false }
          end

          it { should_not be_successful }
          it { should have_message "Resque is DOWN" }
        end
      end
    end

    context "#queued?" do
      it "is true if Resque says the queue has jobs" do
        Resque.should_receive(:info) { {pending: 11} }
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
