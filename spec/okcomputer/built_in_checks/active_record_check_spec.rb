require "spec_helper"

module OKComputer
  describe ActiveRecordCheck do
    it "is a subclass of Check" do
      subject.should be_a Check
    end

    context "#check" do
      let(:version) { "20121205" }
      let(:error_message) { "Error message" }

      context "with a successful connection" do
        before do
          subject.should_receive(:schema_version) { version }
        end

        it { should be_successful }
        it { should have_message "Schema version: #{version}" }
      end

      context "with an unsuccessful connection" do
        before do
          subject.should_receive(:schema_version).and_raise(ActiveRecordCheck::ConnectionFailed, error_message)
        end

        it { should_not be_successful }
        it { should have_message "Failed to connect: '#{error_message}'" }
      end
    end

    context "#version" do
      let(:result) { "123" }
      let(:error_message) { "Wrong password" }

      it "queries from ActiveRecord its installed schema" do
        ActiveRecord::Migrator.should_receive(:current_version) { result }
        subject.schema_version.should == result
      end

      it "raises ConnectionFailed in the event of any error" do
        ActiveRecord::Migrator.should_receive(:current_version).and_raise(StandardError, error_message)
        expect { subject.schema_version }.to raise_error(ActiveRecordCheck::ConnectionFailed, error_message)
      end
    end
  end
end
