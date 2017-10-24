module OkComputer
  # This class performs a health check on a Redis instance using the
  # {INFO command}[http://redis.io/commands/INFO].
  #
  # It reports the Redis instance's memory usage, uptime, and number of
  # connected clients.
  class RedisCheck < Check
    attr_reader :redis_config

    # Public: Initialize a new Redis check.
    #
    # redis_configs - The configuration of the Redis instance.
    #   Expects any valid arguments that can be passed to Redis.new.
    #   See https://github.com/redis/redis-rb#getting-started
    def initialize(*redis_args)
      @redis_args = redis_args
    end

    # Public: Return the status of Redis.
    def check
      info = redis_info

      mark_message "Connected to redis, #{info['used_memory_human']} used memory, uptime #{info['uptime_in_seconds']} secs, #{info['connected_clients']} connected client(s)"
    rescue => e
      mark_failure
      mark_message "Error: '#{e}'"
    end

    # Returns a hash from Redis's INFO command.
    def redis_info
      redis.info
    rescue => e
      raise ConnectionFailed, e
    end

    # Returns a redis instance based on configuration
    def redis
      @redis ||= ::Redis.new(*redis_args)
    end

    ConnectionFailed = Class.new(StandardError)
  end
end
