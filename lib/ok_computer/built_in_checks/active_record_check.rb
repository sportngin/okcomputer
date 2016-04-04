module OkComputer
  class ActiveRecordCheck < Check
    # Public: Return the schema version of the database
    def check
      mark_message "Schema version: #{schema_version}"
    rescue ConnectionFailed => e
      mark_failure
      mark_message "Error: '#{e}'"
    end

    # Public: The scema version of the app's database
    #
    # Returns a String with the version number
    def schema_version
      ActiveRecord::Base.connection_pool.with_connection do |conn|
        ActiveRecord::Migrator.current_version(conn)
      end
    rescue => e
      raise ConnectionFailed, e
    end

    ConnectionFailed = Class.new(StandardError)
  end
end
