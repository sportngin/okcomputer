# Private: Storage of the checks which have been registered with OKComputer.
#
# No one is expected to interact directly with this class, but rather through
# the outer OKComputer interface.
module OKComputer
  class Registry
    # Public: Return the check registered to the given name
    #
    # check_name - The name of the check to retrieve
    #
    # Returns the registered check or raises Registry::CheckNotFound
    def self.fetch(check_name)
      registry.fetch(check_name)
    rescue KeyError
      raise CheckNotFound, "No check registered with '#{check_name}'"
    end

    # Public: Return an object containing all the registered checks
    #
    # Returns a CheckCollection instance
    def self.all
      CheckCollection.new registry
    end

    # Public: Register the given check with OKComputer
    #
    # check_name - The name of the check to retrieve
    # check_object - Instance of Checker to register
    def self.register(check_name, check_object)
      check_object.registrant_name = check_name
      registry[check_name] = check_object
    end

    # Public: Remove the check of the given name being checked
    #
    # check_name - The name of the check to retrieve
    def self.deregister(check_name)
      registry.delete(check_name)
    end

    # Private: The list of registered checks, keyed by their unique names
    #
    # Returns a Hash
    def self.registry
      @registry ||= {}
    end

    # used when fetching a check that has not been registered
    CheckNotFound = Class.new(StandardError)
  end
end
