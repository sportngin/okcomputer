module OKComputer
  class MongoidCheck < Check
    # Public: Return the status of the mongodb
    def check
      mark_message "Successfully connected to mongodb #{mongodb_name}"
    rescue ConnectionFailed => e
      mark_failure
      mark_message "Failed to connect: '#{e}'"
    end

    # Public: The stats for the app's mongodb
    #
    # Returns a hash with the status of the db
    def mongodb_stats
      Mongoid.database.stats
    rescue => e
      raise ConnectionFailed, e
    end

    # Public: The name of the app's mongodb
    #
    # Returns a string with the mongdb name
    def mongodb_name
      mongodb_stats["db"]
    end

    ConnectionFailed = Class.new(StandardError)
  end
end

