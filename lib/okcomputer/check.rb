module OKComputer
  class Check
    CALL_DEPRECATION_MESSAGE = "Deprecation warning: Please define #check rather than defining #call"

    # to be set by Registry upon registration
    attr_accessor :registrant_name
    # nil by default, only set to true if the check deems itself failed
    attr_accessor :failure_occurred
    # nil by default, set by #check to control the output
    attr_accessor :message

    # Public: Run the check
    def run
      clear
      check
    end

    # Private: Perform the appropriate check
    #
    # Your subclass of Check must define its own #check method. This method
    # must return the string to render when performing the check.
    def check
      if respond_to? :call
        warn CALL_DEPRECATION_MESSAGE
        # The old #call methods returned the message, so use that to set the message output
        mark_message call
      else
        raise(CheckNotDefined, "Your subclass must define its own #check.")
      end
    end
    private :check

    # Public: The text output of performing the check
    #
    # Returns a String
    def to_text
      "#{registrant_name}: #{message}"
    end

    # Public: The JSON output of performing the check
    #
    # Returns a String containing JSON
    def to_json(*args)
      # NOTE swallowing the arguments that Rails passes by default since we don't care. This may prove to be a bad idea
      # Rails passes stuff like this: {:prefixes=>["ok_computer", "application"], :template=>"show", :layout=>#<Proc>}]
      {registrant_name => message}.to_json
    end

    # Public: Whether the check passed
    #
    # Returns a boolean
    def success?
      not failure_occurred
    end

    # Public: Mark that this check has failed in some way
    def mark_failure
      self.failure_occurred = true
    end

    # Public: Capture the desired message to display
    #
    # message - Text of the message to display for this check
    def mark_message(message)
      self.message = message
    end

    # Public: Clear any prior failures
    def clear
      self.failure_occurred = false
      self.message = nil
    end

    CheckNotDefined = Class.new(StandardError)
  end
end
