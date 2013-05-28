require "spec_helper"

module OKComputer
  describe Check do
    let(:message) { "message" }

    it "has a name attribute which it does not set" do
      subject.registrant_name.should be_nil
    end

    context "#check" do
      let(:call_response) { "Old #call returns the message" }

      it "raises an exception, to be overwritten by subclasses" do
        expect { subject.send(:check) }.to raise_error(Check::CheckNotDefined)
      end

      context "for legacy checks with #call defined" do
        before do
          subject.should_receive(:respond_to?).with(:call) { true }
        end

        it "warns about #call deprecation, if #call is defined" do
          subject.should_receive(:warn).with(Check::CALL_DEPRECATION_MESSAGE)
          subject.should_receive(:call) { call_response }
          subject.should_receive(:mark_message).with(call_response)

          subject.send(:check)
        end
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
        subject.failure_occurred.should_not be_true
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
        it "combines the registrant_name and message" do
          subject.to_text.should == "#{subject.registrant_name}: #{subject.message}"
        end
      end

      context "#to_json" do
        it "returns JSON with the registrant_name as the key and message as the value" do
          subject.to_json.should == {subject.registrant_name => subject.message}.to_json
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
        subject.failure_occurred.should be_false
        subject.mark_failure
        subject.failure_occurred.should be_true
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
