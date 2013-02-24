module OKComputer
  # Public: Configure HTTP Basic authentication
  #
  # username - Username required to view checks
  # password - Password required to view checks
  def self.require_authentication(username, password)
    self.username = username
    self.password = password
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
  def self.requires_authentication?
    username && password
  end

  # attr_accessor isn't doing what I want inside a module, so here we go.

  # Private: The username configured for access to checks
  def self.username
    @username
  end
  private_class_method :username

  # Private: Configure the username to access checks
  def self.username=(username)
    @username = username
  end
  private_class_method :username=

  # Private: The password configured for access to checks
  def self.password
    @password
  end
  private_class_method :password

  # Private: Configure the password to access checks
  def self.password=(password)
    @password = password
  end
  private_class_method :password=
end
