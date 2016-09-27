require "rails_helper"

module OkComputer
  describe OptionalCheck do
    let(:check) { OkComputer::DefaultCheck.new }

    subject { described_class.new(check) }

    context '#success?' do
      before do
        check.mark_failure
      end

      it { should be_successful }

      it "has a failure message" do
        subject.to_text.should match /FAILED/
      end
    end

    context '#to_text' do
      before do
        check.registrant_name = "foo"
        check.message = "message"
        check.should_not_receive(:call)
        check.mark_failure
      end

      it "combines the upstream data with an optional flag" do
        subject.to_text.should eq "(OPTIONAL) #{check.to_text}"
      end
    end

    context '#to_json' do
      before do
        check.registrant_name = "foo"
        check.message = "message"
        check.should_not_receive(:call)
        check.mark_failure
      end

      it "combines the upstream data with '(OPTIONAL)' string before registrant_name" do
        result_as_hash = JSON.parse subject.to_json
        result_as_hash.keys.size.should eq 1
        result_as_hash.keys.first.should eq  "(OPTIONAL) #{check.registrant_name}"
      end
    end

  end
end
