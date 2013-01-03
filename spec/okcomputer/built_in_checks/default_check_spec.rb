require "spec_helper"

module OKComputer
  describe DefaultCheck do
    it "is a subclass of Check" do
      subject.should be_a Check
    end

    context "#check" do
      it { should be_successful }
      it { should have_message "OKComputer Site Check Passed" }
    end
  end
end
