require "rails_helper"

module OkComputer
  describe Check do
    let(:message) { "message" }

    it "has a name attribute which it does not set" do
      expect(subject.registrant_name).to be_nil
    end

    context "#check" do
      it "raises an exception, to be overwritten by subclasses" do
        expect { subject.send(:check) }.to raise_error(Check::CheckNotDefined)
      end
    end

    context "#run" do
      it "clears any past failures and runs the check" do
        expect(subject).to receive(:clear)
        expect(subject).to receive(:check)
        subject.run
      end

      it "records the execution time for the check" do
        expect(subject).to receive(:clear)
        expect(subject).to receive(:check)
        subject.run
        expect(subject.time).to be >= 0
      end

      it "prints the text to the logger" do
        expect(subject).to receive(:clear)
        expect(subject).to receive(:check)

        subject.registrant_name = "mycheck"
        subject.message = "mymessage"
        expect(OkComputer.logger).to receive(:info).with(/\A\[okcomputer\] mycheck: PASSED mymessage \(.+\)\z/)

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
        expect(subject.failure_occurred).not_to be_truthy
        expect(subject.message).to be_nil
        expect(subject.time).to be_nan
      end
    end

    context "displaying the message captured by #check" do
      before do
        subject.registrant_name = "foo"
        expect(subject).not_to receive(:call)
        subject.message = message
        allow(subject).to receive_messages(time: 5)
      end

      context "#to_text" do
        it "combines the registrant_name, success, message, and execution time" do
          expect(subject.to_text).to eq("#{subject.registrant_name}: PASSED #{subject.message} (5.000s)")
        end
      end

      context "#to_json" do
        before do
          allow(subject).to receive_messages(time: 5)
        end
        it "returns JSON keyed on registrant_name including the message and whether it succeeded" do
          expected = {
            subject.registrant_name => {
              :message => subject.message,
              :success => subject.success?,
              :time => 5
            }
          }
          expect(subject.to_json).to eq(expected.to_json)
        end
      end
    end

    context "#success?" do
      it "is true by default" do
        expect(subject).to be_success
      end

      it "is false if failure_occurred is true" do
        subject.failure_occurred = true
        expect(subject).not_to be_success
      end
    end

    context "#mark_failure" do
      it "sets the failure_occurred occurred boolean" do
        expect(subject.failure_occurred).to be_falsey
        subject.mark_failure
        expect(subject.failure_occurred).to be_truthy
      end
    end

    context "#mark_message" do

      it "sets the check's message" do
        expect(subject.message).to be_nil
        subject.mark_message message
        expect(subject.message).to eq(message)
      end
    end
  end
end
