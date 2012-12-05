module OKComputer
  class Check
    # to be set by Registry upon registration
    attr_accessor :name

    # Public: Perform the appropriate check
    #
    # Your subclass of Check must define its own #call method. This method
    # must return the string to render when performing the check.
    def call
      raise(CallNotDefined, "Your subclass must define its own #call.")
    end

    # Public: The text output of performing the check
    #
    # Returns a String
    def to_text
      "#{name}: #{call}"
    end

    # Public: The JSON output of performing the check
    #
    # Returns a String containing JSON
    def to_json(*args)
      # NOTE swallowing the arguments that Rails passes by default since we don't care. This may prove to be a bad idea
      # Rails passes stuff like this: {:prefixes=>["ok_computer", "application"], :template=>"show", :layout=>#<Proc>}]
      {name => call}.to_json
    end

    CallNotDefined = Class.new(StandardError)
  end
end
