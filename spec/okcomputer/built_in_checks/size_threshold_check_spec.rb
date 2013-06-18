require "spec_helper"

module OKComputer
  describe SizeThresholdCheck do
    let(:size_proc) { lambda{ 123 } }
    let(:threshold) { 100 }
    let(:name) { "name" }

    subject { SizeThresholdCheck.new name, threshold, &size_proc }

    it "is a Check" do
      subject.should be_a Check
    end

    context ".new(name, threshold, &size_proc)" do
      it "accepts a name, a threshold and block that returns the size to consider if it is over the defined threshold" do
        subject.name.should == name
        subject.threshold.should == threshold
        subject.size_proc.should == size_proc
      end

      it "coerces the threshold parameter into an integer" do
        threshold = "123"
        SizeThresholdCheck.new(name, threshold, &size_proc).threshold.should == 123
      end

      it "raises a Type Error if the last argument isn't a proc" do
        size_proc = 123
        lambda { SizeThresholdCheck.new(name, threshold, &size_proc) }.should raise_error(TypeError)
      end
    end

    context "#name" do
      it "should set it to the passed name option" do
        subject.name.should be name
      end
    end

    context "#check" do
      context "with the count less than the threshold" do
        before do
          subject.stub(:size) { threshold - 1 }
        end

        it { should be_successful }
        it { should have_message "#{name} at reasonable level (#{subject.size})" }
      end

      context "with the count equal to the threshold" do
        before do
          subject.stub(:size) { threshold }
        end

        it { should be_successful }
        it { should have_message "#{name} at reasonable level (#{subject.size})" }
      end

      context "with a count greater than the threshold" do
        before do
          subject.stub(:size) { threshold + 1 }
        end

        it { should_not be_successful }
        it { should have_message "#{name} is #{subject.size - subject.threshold} over threshold! (#{subject.size})" }
      end

      context "when #size raises an ArgumentError" do
        before do
          subject.should_receive(:size).and_raise(ArgumentError)
        end

        it { should_not be_successful }
        it { should have_message "The given proc MUST return a number (ArgumentError)" }
      end

      context "when #size raises a TypeError" do
        before do
          subject.should_receive(:size).and_raise(TypeError)
        end

        it { should_not be_successful }
        it { should have_message "The given proc MUST return a number (TypeError)" }
      end

      context "when #size raises any other kind of exception" do
        let(:error) { StandardError.new("some message") }

        before do
          subject.should_receive(:size).and_raise(error)
        end

        it { should_not be_successful }
        it { should have_message "An error occurred: '#{error.message}' (#{error.class})" }
      end
    end

    context "#size" do
      it "defer size to the passed block" do
        size_proc.should_receive(:call).and_return(123)
        subject.size
      end

      it "raises an ArgumentError if the proc doesn't return an Integer" do
        size_proc.should_receive(:call).and_return("not a number")
        expect { subject.size }.to raise_error(ArgumentError)
      end

      it "raises a TypeError if the proc returns nil" do
        size_proc.should_receive(:call).and_return(nil)
        expect { subject.size }.to raise_error(TypeError)
      end
    end
  end
end
