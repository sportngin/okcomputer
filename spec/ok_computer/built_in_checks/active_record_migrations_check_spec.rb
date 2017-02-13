require "rails_helper"

module OkComputer
  describe ActiveRecordMigrationsCheck do
    unless ActiveRecord::Migrator.respond_to?(:needs_migration?)
      before { skip }
    end

    it "is a subclass of Check" do
      subject.should be_a Check
    end

    context '#initialize' do
      context "On active record < 4" do
        before do
          expect(ActiveRecord::Migrator).to receive(:respond_to?).and_return(false)
        end

        subject { -> { ActiveRecordMigrationsCheck.new } }
        it { is_expected.to raise_error(NotImplementedError) }
      end

      context "On active record > 4" do
        before do
          expect(ActiveRecord::Migrator).to receive(:respond_to?).and_return(true)
        end

        it { should be_successful }
      end
    end

    context "#check" do
      context "if activerecord supports needs_migrations?" do
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
end
