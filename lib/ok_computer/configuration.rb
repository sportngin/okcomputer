module OkComputer
  # Public: Configure HTTP Basic authentication
  #
  # username - Username required to view checks
  # password - Password required to view checks
  # options - Hash of additional options
  #   - except - Array of checks to skip authentication for
  #
  # Examples:
  #
  #     OkComputer.require_authentication("foo", "bar")
  #     # => Require authentication with foo:bar for all checks
  #
  #     OkComputer.require_authentication("foo", "bar", except: %w(default nonsecret))
  #     # => Require authentication with foo:bar for all checks except the checks named "default" and "nonsecret"
  def self.require_authentication(username, password, options = {})
    self.username = username
    self.password = password
    self.options = options
  end

  # Public: Attempt to authenticate against required username and password
  #
  # username - Username to authenticate with
  # password - Password to authenticate with
  #
  # Returns a Boolean
  def self.authenticate(username_try, password_try)
    return true unless requires_authentication?

    username == username_try && password == password_try
  end

  # Public: Whether OkComputer is configured to require authentication
  #
  # Returns a Boolean
  def self.requires_authentication?(params={})
    return false if params[:action] == "show" && whitelist.include?(params[:check])

    username && password
  end

  class << self
    # Public: The route to automatically mount the OkComputer engine. Setting to false
    # prevents OkComputer from automatically mounting itself.
    attr_accessor :mount_at

    # Public: whether to execute checks in parallel.
    attr_accessor :check_in_parallel

    # Public: Option to disable third-party app performance tools (.e.g NewRelic) from counting OkComputer routes towards their total.
    attr_accessor :analytics_ignore

    # Private: The username for access to checks
    attr_accessor :username

    # Private: The password for access to checks
    attr_accessor :password

    # Private: The options container
    attr_accessor :options

    # # Private: Configure a whitelist of checks to skip authentication
    def whitelist
      options.fetch(:except) { [] }
    end
  end

  # set default configuration options defined above
  @mount_at = 'okcomputer'
  @check_in_parallel = false
  @analytics_ignore = true
  @options = {}

end
