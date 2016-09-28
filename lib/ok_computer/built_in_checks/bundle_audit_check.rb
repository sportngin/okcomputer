module OkComputer
  ##
  # Utility methods for Bundler::Audit::Advisory
  class BundleAuditAdvisory < SimpleDelegator
    # Evaluate an advisory to offer a solution
    # @return [String] solution
    def solution
      @solution ||= begin
        patches = patched_versions.join(', ')
        if patches.empty?
          'Solution: remove/disable this gem until a patch is available!'
        else
          "Solution: upgrade to #{patches}"
        end
      end
    end

    # Summarize an advisory and offer a solution
    # @return [String] summary
    def summary
      @summary ||= begin
        [
          "Advisory: #{id}",
          "Criticality: #{criticality}",
          "URL: #{url}",
          "Title: #{title}",
          "Description: #{description}",
          solution
        ].join("\n")
      end
    end
  end

  ##
  # Utility methods for Bundler::Audit::Database
  class BundleAuditUpdater
    attr_reader :bundle_database
    attr_reader :messages

    # Public: initialize a bundle-audit updater
    def initialize
      @bundle_database = Bundler::Audit::Database
      @messages = []
    end

    def count
      size = bundle_database.new.size
      messages << "ruby-advisory-db: #{size} advisories"
      size
    end

    # Update the ruby-advisory-db
    def update
      messages << case bundle_database.update!
                  when nil
                    'ruby-advisory-db: skipped update'
                  when true
                    'ruby-advisory-db: updated'
                  when false
                    'ruby-advisory-db: failed to update!'
                  end
    end

    # Are there any useful advisories
    # @return [Boolean] success
    def valid?
      update
      count > 0
    end
  end

  ##
  # Utility methods for Bundler::Audit::Scanner::UnpatchedGem
  class BundleAuditVulnerability < SimpleDelegator
    # Summarize a vulnerability and suggest a solution
    # @return [String] summary
    def summary
      @summary ||= begin
        [
          "GEM: #{gem}",
          BundleAuditAdvisory.new(advisory).summary
        ].join("\n")
      end
    end
  end

  # Audit application gems for security vulnerabilities
  # @see https://github.com/rubysec/bundler-audit
  #
  # Application assumptions:
  # - Gemfile contains:
  #   gem 'bundler-audit', require: false
  # - config/initializers/okcomputer.rb contains
  #   require 'bundler/audit/scanner' # from bundler-audit gem
  #   OkComputer::Registry.register "bundle_audit", BundleAuditCheck.new
  class BundleAuditCheck < Check
    # Public: initialize a bundle-audit check
    # @param [Boolean] verbose output from bundle-audit (false)
    def initialize(verbose = false)
      @audit_updater = BundleAuditUpdater.new
      @audit_scanner = Bundler::Audit::Scanner.new
      @messages = []
      @verbose = verbose
    end

    # Public: Return the status of bundle-audit check
    def check
      msg = if audit_success?
              'BundleAuditCheck is OK!'
            else
              mark_failure
              "Error: BundleAuditCheck failed!\n"
            end
      msg += messages.join("\n") if verbose
      mark_message msg
    end

    private

    attr_reader :audit_updater
    attr_reader :audit_scanner
    attr_reader :messages
    attr_reader :verbose

    # Audit bundled gems for security vulnerabilities
    # @return [Boolean] success
    def audit_success?
      audit_update? && audit_secure?
    end

    # Update the ruby-advisory-db
    # @return [Boolean] success
    def audit_update?
      result = audit_updater.valid?
      messages.concat audit_updater.messages
      result
    end

    # Run bundle-audit
    # @return [Boolean] success
    def audit_secure?
      secure = true
      audit_scanner.scan do |result|
        secure = false
        scanner_messages(result)
      end
      secure
    end

    # Process Bundle::Audit::Scanner messages
    def scanner_messages(result)
      messages << case result
                  when Bundler::Audit::Scanner::InsecureSource
                    "Insecure Source URI found: #{result.source}"
                  when Bundler::Audit::Scanner::UnpatchedGem
                    BundleAuditVulnerability.new(result).summary
                  else
                    "Unknown vulnerability: #{result.class}"
                  end
    end
  end
end
