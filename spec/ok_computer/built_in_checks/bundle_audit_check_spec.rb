require 'rails_helper'
require 'bundler/audit/scanner'

module OkComputer
  describe BundleAuditCheck do
    let(:db) { subject.send(:audit_updater).bundle_database }
    let(:advisory) do
      advisories = db.new.advisories_for('paperclip')
      advisories.find { |adv| adv.id == 'CVE-2015-2963' }
    end

    # Gemfile contains a test group with
    # gem 'paperclip', '< 4.2.2'
    let(:gemspec) { Gem::Specification.find_by_name 'paperclip' }
    let(:gem) do
      Bundler::LazySpecification.new(
        gemspec.name,
        gemspec.version,
        gemspec.platform
      )
    end

    let(:messages) { subject.send(:messages) }
    let(:scanner) { subject.send(:audit_scanner) }

    it 'is a Check' do
      subject.should be_a Check
    end

    describe '#check' do
      context 'with a successful audit' do
        before do
          subject.should_receive(:audit_update?).and_return(true)
          subject.should_receive(:audit_secure?).and_return(true)
        end
        it { should be_successful }
        it { should have_message 'BundleAuditCheck is OK!' }
      end
      context 'with an unsuccessful audit' do
        before do
          subject.should_receive(:audit_update?).and_return(true)
          subject.should_receive(:audit_secure?).and_return(false)
        end
        it { should_not be_successful }
        it { should have_message 'Error: BundleAuditCheck failed!' }
      end
    end

    ##
    # PRIVATE METHODS
    # Specs to provide 100% coverage and to ensure
    # the dependencies on Bundle::Audit behaves as expected.

    describe '#audit_update?' do
      let(:update) { subject.send(:audit_update?) }
      before do
        db_new = db.new
        allow(db).to receive(:new).and_return(db_new)
        allow(db_new).to receive(:size).and_return(10)
      end
      context 'update is true' do
        before do
          expect(db).to receive(:update!).and_return(true)
        end
        it 'returns true' do
          expect(update).to be true
        end
        it 'appends to verbose messages' do
          update
          expect(messages).to include 'ruby-advisory-db: updated'
          expect(messages).to include 'ruby-advisory-db: 10 advisories'
        end
      end
      context 'update is nil' do
        before do
          expect(db).to receive(:update!).and_return(nil)
        end
        it 'returns true' do
          expect(update).to be true
        end
        it 'appends to verbose messages' do
          update
          expect(messages).to include 'ruby-advisory-db: skipped update'
          expect(messages).to include 'ruby-advisory-db: 10 advisories'
        end
      end
      context 'update is false' do
        before do
          expect(db).to receive(:update!).and_return(false)
        end
        context 'when there are useful advisories' do
          it 'returns true' do
            expect(update).to be true
          end
          it 'appends to verbose messages' do
            update
            expect(messages).to include 'ruby-advisory-db: failed to update!'
            expect(messages).to include 'ruby-advisory-db: 10 advisories'
          end
        end
        context 'when there are no advisories' do
          before do
            db_new = db.new
            allow(db).to receive(:new).and_return(db_new)
            allow(db_new).to receive(:size).and_return(0)
          end
          it 'returns false' do
            expect(update).to be false
          end
          it 'appends to verbose messages' do
            update
            expect(messages).to include 'ruby-advisory-db: failed to update!'
            expect(messages).to include 'ruby-advisory-db: 0 advisories'
          end
        end
      end
    end

    describe '#audit_secure?' do
      let(:secure) { subject.send(:audit_secure?) }
      before do
        allow(subject).to receive(:audit_update?).and_return(true)
      end
      context 'secure is true' do
        before do
          # Stub the scanner.scan so it yields no vulnerabilities
          expect(scanner).to receive(:scan).at_least(:once)
        end
        it 'returns true' do
          expect { |block| scanner.scan(&block) }.not_to yield_control
          expect(secure).to be true
        end
        it 'does not append anything to verbose messages' do
          secure
          expect(messages).not_to include(/^GEM:/)
        end
      end
      context 'secure is false' do
        # The Gemfile includes a vulnerable gem in the test group, so this
        # context has a genuine vulnerability to work with.
        it 'returns false' do
          expect(secure).to be false
        end
        it 'appends to verbose messages' do
          secure
          expect(messages).to include(/^GEM: #{gem.name}/)
        end
      end
    end

    describe '#scanner_messages' do
      context 'result is a Bundler::Audit::Scanner::InsecureSource' do
        let(:result) do
          Bundler::Audit::Scanner::InsecureSource.new('http://rubygems.org')
        end
        it 'adds a warning about an insecure gem source to messages' do
          subject.send(:scanner_messages, result)
          expect(messages.last).to eq "Insecure Source URI found: #{result.source}"
        end
      end
      context 'result is a Bundler::Audit::Scanner::UnpatchedGem' do
        let(:result) do
          Bundler::Audit::Scanner::UnpatchedGem.new(gem, advisory)
        end
        before do
          expect(OkComputer::BundleAuditVulnerability).to receive(:new).and_call_original
          expect(OkComputer::BundleAuditAdvisory).to receive(:new).and_call_original
        end
        it 'adds a summary of the gem advisory to messages' do
          subject.send(:scanner_messages, result)
          expect(messages.last).to include gem.to_s
          expect(messages.last).to include 'Solution: upgrade'
        end
        it 'recommends removing a gem without a security patch' do
          expect(advisory).to receive(:patched_versions).and_return([])
          subject.send(:scanner_messages, result)
          expect(messages.last).to include gem.to_s
          expect(messages.last).to include 'Solution: remove/disable this gem'
        end
      end
      context 'result is unknown' do
        let(:result) { double(String) }
        it 'adds an unknown vulnerability to messages' do
          subject.send(:scanner_messages, result)
          expect(messages.last).to include 'Unknown vulnerability'
        end
      end
    end
  end
end
