require "rails_helper"

module OkComputer
  describe ActiveRecordMigrationsCheck do
    it "is a subclass of Check" do
      subject.should be_a Check
    end

    context "#check" do
      context "with no pending migrations" do
        before do
          expect(ActiveRecord::Migrator).to receive(:needs_migration?).and_return(false)
        end

        it { should be_successful }
        it { should have_message "NO pending migrations" }
      end

      context "with pending migrations" do
        before do
          expect(ActiveRecord::Migrator).to receive(:needs_migration?).and_return(true)
        end

        it { should_not be_successful }
        it { should have_message "Pending migrations" }
      end
    end
  end
end
