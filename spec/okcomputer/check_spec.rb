require "spec_helper"

module OKComputer
  describe Check do
    it "has a name attribute which it does not set" do
      subject.name.should be_nil
    end

    context "#call" do
      it "raises an exception, to be overwritten by subclasses" do
        expect { subject.call }.to raise_error(Check::CallNotDefined)
      end
    end

    context "displaying the output of #call" do
      before do
        subject.name = "foo"
        subject.stub(call: "Everything is great!")
      end

      context "#to_text" do
        it "combines the name and result of #call" do
          subject.to_text.should == "#{subject.name}: #{subject.call}"
        end
      end

      context "#to_json" do
        it "returns JSON with the name as the key and result of call as the value" do
          subject.to_json.should == {subject.name => subject.call}.to_json
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
  end
end
