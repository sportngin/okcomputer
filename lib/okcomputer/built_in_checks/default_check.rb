module OKComputer
  class DefaultCheck < Check
    # Public: Check that Rails can render anything at all
    def call
      "OKComputer Site Check Passed"
    end
  end
end
