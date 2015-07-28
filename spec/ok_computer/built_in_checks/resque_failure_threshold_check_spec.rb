# Stubbing the constant out; will exist in apps which have Resque loaded
class Resque; class Failure; end; end

module OkComputer
  describe ResqueFailureThresholdCheck do
    let(:threshold) { 100 }

    subject { ResqueFailureThresholdCheck.new threshold }

    it "is a Check" do
      subject.should be_a Check
    end

    context ".new(queue, threshold)" do
      it "accepts a queue name and a threshold to consider backed up" do
        subject.threshold.should == threshold
      end

      it "coerces the threshold parameter into an integer" do
        threshold = "123"
        ResqueFailureThresholdCheck.new(threshold).threshold.should == 123
      end
    end

    context "#check" do
      let(:status) { "status text" }

      context "with the count less than the threshold" do
        before do
          subject.stub(:size) { threshold - 1 }
        end

        it { should be_successful }
        it { should have_message "Resque Failed Jobs at reasonable level (#{subject.size})" }
      end

      context "with the count equal to the threshold" do
        before do
          subject.stub(:size) { threshold }
        end

        it { should be_successful }
        it { should have_message "Resque Failed Jobs at reasonable level (#{subject.size})" }
      end

      context "with a count greater than the threshold" do
        before do
          subject.stub(:size) { threshold + 1 }
        end

        it { should_not be_successful }
        it { should have_message "Resque Failed Jobs is #{subject.size - subject.threshold} over threshold! (#{subject.size})" }
      end
    end

    context "#size" do
      let(:size) { 123 }

      it "defers to Resque for the job count" do
        Resque::Failure.should_receive(:count) { size }
        subject.size.should == size
      end
    end
  end
end
