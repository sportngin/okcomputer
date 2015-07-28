module OkComputer
  describe RubyVersionCheck do
    it "is a subclass of Check" do
      subject.should be_a Check
    end

    context "#check" do
      it { should be_successful }
      it { should have_message "Ruby #{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}" }
    end
  end
end
