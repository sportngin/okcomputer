require "rails_helper"

module OkComputer
  describe ActiveRecordMigrationsCheck do
    it "is a subclass of Check" do
      subject.should be_a Check
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

      context "if ActiveRecord doesn't support needs_migratons?" do
        context "with no pending migrations" do
          before do
            versions = [instance_double('version', :version => '20160510232542')]
            expect(ActiveRecord::Migrator).to receive_messages(
              respond_to?: false,
              get_all_versions: ['20160510232542'],
              migrations: versions
            )
          end

          it { should be_successful }
          it { should have_message "NO pending migrations" }
        end

        context "with pending migrations" do
          before do
            versions = [instance_double('version', :version => '20160510232542')]

            expect(ActiveRecord::Migrator).to receive_messages(
              respond_to?: false,
              get_all_versions: [],
              migrations: versions
            )
          end

          it { should_not be_successful }
          it { should have_message "Pending migrations" }
        end
      end
    end
  end
end
