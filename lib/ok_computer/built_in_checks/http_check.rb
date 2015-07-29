require "net/http"

module OkComputer
  # Performs a health check by reading a URL over HTTP.
  # A successful response is considered passing.
  # To implement your own pass/fail criteria, inherit from this
  # class, override #check, and call #perform_request to get the
  # response body.
  class HttpCheck < Check
    ConnectionFailed = Class.new(StandardError)

    attr_accessor :url
    attr_accessor :request_timeout

    # Public: Initialize a new HTTP check.
    #
    # url - The URL to check
    # request_timeout - How long to wait to connect before timing out. Defaults to 5 seconds.
    def initialize(url, request_timeout = 5)
      self.url = URI(url)
      self.request_timeout = request_timeout.to_i
    end

    # Public: Return the status of the HTTP check
    def check
      if perform_request
        mark_message "HTTP check successful"
      end
    rescue => e
      mark_message "Error: '#{e}'"
      mark_failure
    end

    # Public: Actually performs the request against the URL.
    # Returns response body if the request was successful.
    # Otherwise raises a HttpCheck::ConnectionFailed error.
    def perform_request
      timeout(request_timeout) do
        req = Net::HTTP::Get.new(url.request_uri)
        req.basic_auth(url.user, url.password) if url.user || url.password

        http = Net::HTTP.new(url.hostname, url.port)
        http.read_timeout = request_timeout
        http.use_ssl = url.scheme == 'https'

        http.request(req).body
      end
    rescue => e
      raise ConnectionFailed, e
    end
  end
end
