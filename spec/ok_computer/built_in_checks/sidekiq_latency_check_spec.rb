# Stubbing the constant out; will exist in apps which have Sidekiq loaded
module Sidekiq
  class Queue
    def initialize(queue)
    end
  end
end

module OkComputer
  describe ResqueBackedUpCheck do
    let(:queue) { "queue name" }
    let(:threshold) { 30 }

    subject { SidekiqLatencyCheck.new queue, threshold }

    it "is a Check" do
      subject.should be_a Check
    end

    context ".new(queue, threshold)" do
      it "accepts a queue name and a latency threshold to consider backed up" do
        subject.queue.should == queue
        subject.threshold.should == threshold
      end

      it "coerces the threshold parameter into an integer" do
        threshold = "30"
        described_class.new(queue, threshold).threshold.should == 30
      end
    end

    context "#check" do
      let(:status) { "status text" }

      context "with the count less than the threshold" do
        before do
          subject.stub(:size) { threshold - 1 }
        end

        it { should be_successful }
        it { should have_message "Sidekiq queue '#{queue}' latency at reasonable level (#{subject.size})" }
      end

      context "with the count equal to the threshold" do
        before do
          subject.stub(:size) { threshold }
        end

        it { should be_successful }
        it { should have_message "Sidekiq queue '#{queue}' latency at reasonable level (#{subject.size})" }
      end

      context "with a count greater than the threshold" do
        before do
          subject.stub(:size) { threshold + 1 }
        end

        it { should_not be_successful }
        it { should have_message "Sidekiq queue '#{queue}' latency is #{subject.size - subject.threshold} over threshold! (#{subject.size})" }
      end
    end

    context "#size" do
      let(:size) { 30 }
      let(:sidekiq_queue) { double(queue) }

      before do
        Sidekiq::Queue.stub(:new) { sidekiq_queue }
      end

      it "defers to Sidekiq for the job count" do
        sidekiq_queue.should_receive(:latency) { size }
        subject.size.should == size
      end
    end
  end
end
