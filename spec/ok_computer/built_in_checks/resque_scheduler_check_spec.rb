require "rails_helper"

# Stubbing the constant out; will exist in apps which have Resque loaded
class Resque; end

module OkComputer
  describe ResqueSchedulerCheck do
    it "is a Check" do
      expect(subject).to be_a Check
    end

    context "#check" do
      context "with resque scheduler working" do
        before do
          allow(subject).to receive(:working?) { true }
        end

        it { is_expected.to be_successful }
        it { is_expected.to have_message "Resque Scheduler is UP" }
      end

      context "with resque scheduler not working" do
        before do
          allow(subject).to receive(:working?) { false }
        end

        it { is_expected.not_to be_successful }
        it { is_expected.to have_message "Resque Scheduler is DOWN" }
      end
    end

    context "#working?" do
      it "is true if resque scheduler key is found" do
        expect(Resque).to receive(:keys) { ['resque_scheduler_master_lock'] }
        expect(subject).to be_working
      end

      it "is false if resque scheduler key is not found" do
        expect(Resque).to receive(:keys) { [] }
        expect(subject).not_to be_working
      end
    end
  end
end
