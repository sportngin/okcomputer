# Stubbing the constant out; will exist in apps which have
# Delayed Job loaded
module Delayed
  class Job; end
end

module OkComputer
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

      it "sets greater_than_priority to false" do
        DelayedJobBackedUpCheck.new(priority, "123").greater_than_priority.should == false
      end
    end

    context ".new(priority, threshold, :greater_than_priority => true)" do
      it "accepts an options hash, and assigns variables correctly" do
        DelayedJobBackedUpCheck.new(priority, threshold, :greater_than_priority => true).greater_than_priority.should == true
      end
    end

    context "#check" do
      context "when not backed up" do
        before do
          subject.stub(:size) { 99 }
        end

        it { should be_successful }
        it { should have_message "Delayed Jobs with priority lower than '#{subject.priority}' at reasonable level (#{subject.size})"}
      end

      context "when backed up" do
        before do
          subject.stub(:size) { 123 }
        end

        it { should_not be_successful }
        it { should have_message "Delayed Jobs with priority lower than '#{subject.priority}' is #{subject.size - subject.threshold} over threshold! (#{subject.size})"}
      end

      context "with greater_than_priority == true" do
        subject { DelayedJobBackedUpCheck.new priority, threshold , :greater_than_priority =>  true }
        context "when not backed up" do
          before do
            subject.stub(:size) { 89 }
          end

          it { should be_successful }
          it { should have_message "Delayed Jobs with priority higher than '#{subject.priority}' at reasonable level (#{subject.size})"}
        end

        context "when backed up" do
          before do
            subject.stub(:size) { 123 }
          end

          it { should_not be_successful }
          it { should have_message "Delayed Jobs with priority higher than '#{subject.priority}' is #{subject.size - subject.threshold} over threshold! (#{subject.size})"}
        end
      end
    end

    context "#size" do

      context "when Mongoid defined" do
        before do
          stub_const('Delayed::Backend::Mongoid::Job', Object.new)
          stub_const('Delayed::Worker', Object.new).should_receive(:backend).and_return(Delayed::Backend::Mongoid::Job)
        end

        it "checks Delayed::Job's count of pending jobs within the given priority" do
          Delayed::Job.should_receive(:lte).with(priority: priority).and_return(Delayed::Job)
          Delayed::Job.should_receive(:where).with(:locked_at => nil, :last_error => nil).and_return(Delayed::Job)
          Delayed::Job.should_receive(:count).with(no_args()).and_return(456)
          subject.size.should eq 456
        end
      end

      context "when Mongoid not defined" do
        before { hide_const 'Delayed::Backend::Mongoid::Job' }

        it "checks Delayed::Job's count of pending jobs within the given priority" do
          Delayed::Job.should_receive(:where).with("priority <= ?", priority).and_return(Delayed::Job)
          Delayed::Job.should_receive(:where).with(:locked_at => nil, :last_error => nil).and_return(Delayed::Job)
          Delayed::Job.should_receive(:count).with(no_args()).and_return(456)
          subject.size.should eq 456
        end
      end

      context "with greater_than_priority == true" do
        subject { DelayedJobBackedUpCheck.new priority, threshold , :greater_than_priority =>  true }
        context "when Mongoid defined" do
          before do
            stub_const('Delayed::Backend::Mongoid::Job', Object.new)
            stub_const('Delayed::Worker', Object.new).should_receive(:backend).and_return(Delayed::Backend::Mongoid::Job)
          end

          it "checks Delayed::Job's count of pending jobs within the given priority" do
            Delayed::Job.should_receive(:gte).with(priority: priority).and_return(Delayed::Job)
            Delayed::Job.should_receive(:where).with(:locked_at => nil, :last_error => nil).and_return(Delayed::Job)
            Delayed::Job.should_receive(:count).with(no_args()).and_return(456)
            subject.size.should eq 456
          end
        end

        context "when Mongoid not defined" do
          before { hide_const 'Delayed::Backend::Mongoid::Job' }

          it "checks Delayed::Job's count of pending jobs within the given priority" do
            Delayed::Job.should_receive(:where).with("priority >= ?", priority).and_return(Delayed::Job)
            Delayed::Job.should_receive(:where).with(:locked_at => nil, :last_error => nil).and_return(Delayed::Job)
            Delayed::Job.should_receive(:count).with(no_args()).and_return(456)
            subject.size.should eq 456
          end
        end
      end
    end
  end
end
