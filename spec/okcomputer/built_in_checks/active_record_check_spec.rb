require "spec_helper"

module OKComputer
  describe ActiveRecordCheck do
    it "is a subclass of Check" do
      subject.should be_a Check
    end

    context "#call" do
      let(:version) { "20121205" }
      let(:error_message) { "Error message" }

      it "confirms connection to the database" do
        subject.should_receive(:schema_version) { version }
        subject.call.should == "Schema version: #{version}"
        subject.should be_success
      end

      it "returns a valid failure message" do
        subject.should_receive(:schema_version).and_raise(ActiveRecordCheck::ConnectionFailed, error_message)
        subject.call.should == "Failed to connect: '#{error_message}'"
        subject.should_not be_success
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
