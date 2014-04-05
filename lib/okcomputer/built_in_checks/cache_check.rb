module OKComputer
  class CacheCheck < Check

    ConnectionFailed = Class.new(StandardError)

    # Public: Check whether the cache is active
    def check
      mark_message "Cache is available (#{stats})"
    rescue ConnectionFailed => e
      mark_failure
      mark_message "Error: '#{e}'"
    end

    # Public: Outputs stats string for cache
    def stats
      stats = Rails.cache.stats
      mem_used = to_megabytes stats['bytes']
      mem_max  = to_megabytes stats['limit_maxbytes']
      return "#{mem_used} / #{mem_max} MB"
    rescue => e
      raise ConnectionFailed, e
    end

    private

    # Private: Convert bytes to megabytes
    def to_megabytes(bytes)
      bytes.to_i / (1024 * 1024)
    end
  end
end
