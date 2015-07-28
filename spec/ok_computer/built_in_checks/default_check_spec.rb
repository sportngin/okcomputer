module OkComputer
  describe DefaultCheck do
    it "is a subclass of Check" do
      subject.should be_a Check
    end

    context "#check" do
      it { should be_successful }
      it { should have_message "Application is running" }
    end
  end
end
