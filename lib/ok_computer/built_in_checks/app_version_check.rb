module OkComputer
  # Display app version SHA
  #
  # * If `ENV["SHA"]` is set, uses that value.
  # * Otherwise, checks for Capistrano's REVISION file in the app root.
  # * Failing these, the check fails
  class AppVersionCheck < Check
    # Public: Return the application version
    def check
      mark_message "Version: #{version}"
    rescue UnknownRevision
      mark_failure
      mark_message "Unable to determine version"
    end

    # Public: The application version
    #
    # Returns a String
    def version
      version_from_env || version_from_revision_file || entry_from_revisions_log || raise(UnknownRevision)
    end

    private

    # Private: Version stored in environment variable
    def version_from_env
      ENV["SHA"]
    end

    # Private: Version/SHA stored in REVISION file at Rails.root (e.g. by Capistrano < version 3)
    def version_from_revision_file
      if File.exist?(Rails.root.join("REVISION"))
        File.read(Rails.root.join("REVISION")).chomp
      end
    end

    # Private: entry stored in Capistrano 3 revisions.log file one up from Rails.root
    #   return last entry indicating a SHA was deployed, unless the last line in the log is
    #   a rollback entry.  In this case, return the entry indicating the deployed release.
    def entry_from_revisions_log
      revisions_log_path = Rails.root.join("..", "revisions.log")
      if File.exist? revisions_log_path
        lines = File.open(revisions_log_path).to_a
        rollback_release = nil
        lines.reverse.each do |line|
          if rollback_release
            release_scan = line.scan(/^Branch .* \(at \w+\) deployed as release (\w+) by.*/)
            if release_scan.respond_to?(:first) && release_scan.first.respond_to?(:first)
              return line if rollback_release == release_scan.first.first
            end
          else
            scan_results = line.scan(/^Branch .* \(at (\w+)\) deployed.*/)
            if scan_results.respond_to?(:first) && scan_results.first.respond_to?(:first)
              return line
            else
              rollback_scan = line.scan(/rolled back to release (\w+)$/)
              if rollback_scan.respond_to?(:first) && rollback_scan.first.respond_to?(:first)
                rollback_release = rollback_scan.first.first
              end
            end
          end
        end
      end
    end

    UnknownRevision = Class.new(StandardError)
  end
end
