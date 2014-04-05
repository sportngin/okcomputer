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
      context "when not backed up" do
        before do
          subject.stub(:size) { 99 }
        end

        it { should be_successful }
        it { should have_message "Delayed Jobs within priority '#{subject.priority}' at reasonable level (#{subject.size})"}
      end

      context "when backed up" do
        before do
          subject.stub(:size) { 123 }
        end

        it { should_not be_successful }
        it { should have_message "Delayed Jobs within priority '#{subject.priority}' is #{subject.size - subject.threshold} over threshold! (#{subject.size})"}
      end
    end

    context "#size" do

      context "when Mongoid defined" do
        before { stub_const 'Mongoid', Object.new }

        it "checks Delayed::Job's count of pending jobs within the given priority" do
          Delayed::Job.stub(:lte).and_return(Delayed::Job)
          Delayed::Job.stub(:where).and_return(Delayed::Job)
          Delayed::Job.stub(:count).and_return(456)
          Delayed::Job.should_receive(:lte).with(priority: priority)
          Delayed::Job.should_receive(:where).with(:locked_at => nil, :last_error => nil)
          Delayed::Job.should_receive(:count).with(no_args())
          subject.size.should eq 456
        end
      end

      context "when Mongoid not defined" do

        it "checks Delayed::Job's count of pending jobs within the given priority" do
          Delayed::Job.stub(:where).and_return(Delayed::Job)
          Delayed::Job.stub(:count).and_return(456)
          Delayed::Job.should_receive(:where).with("priority <= ?", priority)
          Delayed::Job.should_receive(:where).with(:locked_at => nil, :last_error => nil)
          Delayed::Job.should_receive(:count).with(no_args())
          subject.size.should eq 456
        end
      end
    end
  end
end
