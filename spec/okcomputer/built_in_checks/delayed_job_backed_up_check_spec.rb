require "spec_helper"

# Stubbing the constant out; will exist in apps which have
# Delayed Job loaded
module Delayed
  class Job; end
end

module OKComputer
  describe DelayedJobBackedUpCheck do
    let(:priority) { 10 }
    let(:threshold) { 100 }

    subject { DelayedJobBackedUpCheck.new priority, threshold }

    it "is a Check" do
      subject.should be_a Check
    end

    context ".new(priority, threshold)" do
      it "accepts a priority and a threshold to consider backed up" do
        subject.priority.should == priority
        subject.threshold.should == threshold
      end

      it "coerces priority into an integer" do
        DelayedJobBackedUpCheck.new("123", threshold).priority.should == 123
      end

      it "coercese threshold into an integer" do
        DelayedJobBackedUpCheck.new(priority, "123").threshold.should == 123
      end
    end

    context "#check" do
      before do
        subject.stub(:count) { 123 }
      end

      context "when not backed up" do
        before do
          subject.stub(:backed_up?) { false }
        end

        it { should be_successful }
        it { should have_message "Delayed Jobs within priority '#{priority}' at reasonable level (#{subject.count})"}
      end

      context "when backed up" do
        before do
          subject.stub(:backed_up?) { true }
        end

        it { should_not be_successful }
        it { should have_message "Delayed Jobs within priority '#{priority}' backed up! (#{subject.count})"}
      end
    end

    context "#backed_up?" do
      it "is true if the count is greater than the threshold" do
        subject.stub(:count) { threshold + 1 }
        subject.should be_backed_up
      end

      it "is false if the count is equal to the threshold" do
        subject.stub(:count) { threshold }
        subject.should_not be_backed_up
      end

      it "is false if the count is less than the threshold" do
        subject.stub(:count) { threshold - 1 }
        subject.should_not be_backed_up
      end
    end

    context "#count" do
      it "checks Delayed::Job's count of pending jobs within the given priority" do
        pending("looking for a non-terrible way to test this. would like a scope that returns this with a single call (like with Resque check)")
      end
    end
  end
end
