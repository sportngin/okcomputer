module OKComputer
  class CheckCollection
    attr_accessor :registry

    # Public: Initialize a new CheckCollection
    #
    # registry - a Hash of checks, with keys being unique names and values
    #   being Check instances
    def initialize(registry={})
      self.registry = registry
    end

    # Public: Run the registry's checks
    def run
      checks.each(&:run)
    end

    # Public: The list of checks in the collection
    #
    # Returns an Array of the registry's values
    def checks
      registry.values
    end

    # Public: The text of each check in the collection
    #
    # Returns a String
    def to_text
      checks.map(&:to_text).join("\n")
    end

    # Public: The JSON of each check in the collection
    #
    # Returns a String containing a JSON array of hashes
    def to_json(*args)
      # smooshing their #to_json objects into one JSON hash
      combined = {}
      checks.each do |check|
        combined.merge!(JSON.parse(check.to_json))
      end

      combined.to_json
    end

    # Public: Whether all the checks succeed
    #
    # Returns a Boolean
    def success?
      checks.all?(&:success?)
    end
  end
end
