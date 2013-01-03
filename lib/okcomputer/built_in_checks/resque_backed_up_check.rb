module OKComputer
  class ResqueBackedUpCheck < Check
    attr_accessor :queue
    attr_accessor :threshold

    # Public: Initialize a check for a backed-up Resque queue
    #
    # queue - The name of the Resque queue to check
    # threshold - An Integer to compare the queue's count against to consider
    #   it backed up
    def initialize(queue, threshold)
      self.queue = queue
      self.threshold = Integer(threshold)
    end

    # Public: Check whether the given queue is backed up
    def check
      if count <= threshold
        mark_message "Resque queue '#{queue}' at reasonable level (#{count})"
      else
        mark_failure
        mark_message "Resque queue '#{queue}' backed up! (#{count})"
      end
    end

    # Public: The number of jobs in the check's queue
    def count
      Resque.size(queue)
    end
  end
end
