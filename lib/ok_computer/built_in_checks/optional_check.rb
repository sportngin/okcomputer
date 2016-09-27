require 'delegate'

module OkComputer
  # This check wraps another check and forces it to be successful so as to
  # avoid triggering alerts.
  class OptionalCheck < SimpleDelegator
    # Public: Always successful
    def success?
      true
    end

    # Public: The text output of performing the check
    #
    # '(OPTIONAL)' implies the result of the check doesn't impact overall success
    # Returns a String
    def to_text
      "(OPTIONAL) #{__getobj__.to_text}"
    end

    # Public: The JSON output of performing the check
    #
    # Returns a String containing JSON
    def to_json(*args)
      orig_as_hash = JSON.parse(__getobj__.to_json(args))
      if orig_as_hash.keys.size == 1
        orig_hash_key = orig_as_hash.keys.first
        orig_hash_value = orig_as_hash[orig_hash_key]
        new_hash = { "(OPTIONAL) #{orig_hash_key}" => orig_hash_value}
        return new_hash.to_json
      else
        return __getobj__.to_json(args)
      end
    end
  end
end
