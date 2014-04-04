module OKComputer
  # Public: Configure HTTP Basic authentication
  #
  # username - Username required to view checks
  # password - Password required to view checks
  # options - Hash of additional options
  #   - except - Array of checks to skip authentication for
  #
  # Examples:
  #
  #     OKComputer.require_authentication("foo", "bar")
  #     # => Require authentication with foo:bar for all checks
  #
  #     OKComputer.require_authentication("foo", "bar", except: %w(default nonsecret))
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

  # Public: Whether OKComputer is configured to require authentication
  #
  # Returns a Boolean
  def self.requires_authentication?(params={})
    return false if params[:action] == "show" && whitelist.include?(params[:check])

    username && password
  end

  # Private: The username for access to checks
  mattr_accessor :username
  private_class_method :username
  private_class_method :username=

  # Private: The password for access to checks
  mattr_accessor :password
  private_class_method :password
  private_class_method :password=

  # Private: The options container
  mattr_accessor :options
  self.options = {}

  # Private: Configure a whitelist of checks to skip authentication
  def self.whitelist
    options.fetch(:except) { [] }
  end
end
