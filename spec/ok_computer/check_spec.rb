module OkComputer
  describe Check do
    let(:message) { "message" }

    it "has a name attribute which it does not set" do
      subject.registrant_name.should be_nil
    end

    context "#check" do
      it "raises an exception, to be overwritten by subclasses" do
        expect { subject.send(:check) }.to raise_error(Check::CheckNotDefined)
      end
    end

    context "#run" do
      it "clears any past failures and runs the check" do
        subject.should_receive(:clear)
        subject.should_receive(:check)
        subject.run
      end
    end

    context "#clear" do
      before do
        subject.failure_occurred = true
        subject.message = "asdf"
      end

      it "removes the failure_occurred flag" do
        subject.clear
        subject.failure_occurred.should_not be_truthy
        subject.message.should be_nil
      end
    end

    context "displaying the message captured by #check" do
      before do
        subject.registrant_name = "foo"
        subject.should_not_receive(:call)
        subject.message = message
      end

      context "#to_text" do
        it "combines the registrant_name, success, and message" do
          subject.to_text.should == "#{subject.registrant_name}: PASSED #{subject.message}"
        end
      end

      context "#to_json" do
        it "returns JSON keyed on registrant_name including the message and whether it succeeded" do
          expected = {
            subject.registrant_name => {
              :message => subject.message,
              :success => subject.success?,
            }
          }
          subject.to_json.should == expected.to_json
        end
      end
    end

    context "#success?" do
      it "is true by default" do
        subject.should be_success
      end

      it "is false if failure_occurred is true" do
        subject.failure_occurred = true
        subject.should_not be_success
      end
    end

    context "#mark_failure" do
      it "sets the failure_occurred occurred boolean" do
        subject.failure_occurred.should be_falsey
        subject.mark_failure
        subject.failure_occurred.should be_truthy
      end
    end

    context "#mark_message" do

      it "sets the check's message" do
        subject.message.should be_nil
        subject.mark_message message
        subject.message.should == message
      end
    end
  end
end
