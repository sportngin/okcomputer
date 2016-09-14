require "rails_helper"

module OkComputer
  describe AppVersionCheck do
    it "is a subclass of Check" do
      subject.should be_a Check
    end

    context "#check" do
      let(:version) { "sha" }

      context "when able to deterimine the version" do
        before do
          subject.should_receive(:version).and_return(version)
        end

        it { should be_successful }
        it { should have_message "Version: #{version}" }
      end

      context "when unable to determine the version" do
        before do
          subject.should_receive(:version).
            and_raise(AppVersionCheck::UnknownRevision)
        end

        it { should_not be_successful }
        it { should have_message "Unable to determine version" }
      end
    end

    context "#version" do
      let(:version) { "version" }
      let(:revision_path) { Rails.root.join("REVISION") }
      let(:revisions_log_path) { Rails.root.join('..', 'revisions.log') }

      context "with the SHA environment variable set" do
        around(:example) do |example|
          with_env("SHA" => version) do
            example.run
          end
        end

        it "returns the contents of SHA" do
          expect(subject.version).to eq(version)
        end
      end

      context "with a REVISION file at the root of the app directory" do
        around(:example) do |example|
          with_env("SHA" => nil) do
            example.run
          end
        end

        before do
          File.should_receive(:exist?).with(revision_path).and_return(true)
          File.should_receive(:read).with(revision_path).and_return("#{version}\n")
        end

        it "returns the contents of the file" do
          expect(subject.version).to eq(version)
        end
      end

      context "with a revisions.log file at the root of the app directory" do
        let(:revisions_log_entry_1) { "Branch master (at d9dc55950) deployed as release 20160821211111 by janedoe\n" }
        let(:revisions_log_entry_2) {"Branch master (at 431b7e3dea) deployed as release 20160823233333 by jdoe\n"}
        let(:revision_log_contents) { [revisions_log_entry_1, revisions_log_entry_2] }
        around(:example) do |example|
          with_env("SHA" => nil) do
            example.run
          end
        end

        before do
          File.should_receive(:exist?).with(revision_path).and_return(false)
          File.should_receive(:exist?).with(revisions_log_path).and_return(true)
        end

        it "returns the log entry from the last file entry when it has a sha" do
          File.should_receive(:open).with(revisions_log_path).and_return(revision_log_contents)
          expect(subject.version).to eq(revisions_log_entry_2)
        end
        it "rollback message returns the matching release entry" do
          revision_log_contents << "jdoe rolled back to release 20160823233333\n"
          File.should_receive(:open).with(revisions_log_path).and_return(revision_log_contents)
          expect(subject.version).to eq(revisions_log_entry_2)
        end
        it 'rollback message returns the matching release entry even if it skips back' do
          revision_log_contents << "jdoe rolled back to release 20160821211111\n"
          File.should_receive(:open).with(revisions_log_path).and_return(revision_log_contents)
          expect(subject.version).to eq(revisions_log_entry_1)
        end
      end

      context "without these" do
        around(:example) do |example|
          with_env("SHA" => nil) do
            example.run
          end
        end

        before do
          File.should_receive(:exist?).with(revision_path).and_return(false)
          File.should_receive(:exist?).with(revisions_log_path).and_return(false)
        end

        it "raises an exception" do
          expect {
            subject.version
          }.to raise_error(AppVersionCheck::UnknownRevision)
        end
      end
    end
  end
end
