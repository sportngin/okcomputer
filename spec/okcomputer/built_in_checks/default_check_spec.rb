require "spec_helper"

module OKComputer
  describe DefaultCheck do
    it "is a subclass of Check" do
      subject.should be_a Check
    end

    context "#call" do
      it "simply outputs a string to render" do
        subject.call.should include "OKComputer Site Check Passed"
      end
    end
  end
end
