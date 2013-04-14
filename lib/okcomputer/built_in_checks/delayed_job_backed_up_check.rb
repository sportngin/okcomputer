module OKComputer
  class DelayedJobBackedUpCheck < Check
    attr_accessor :priority
    attr_accessor :threshold

    # Public: Initialize a check for backed-up Delayed Job jobs
    #
    # priority - Which priority (or greater) to check for
    # threshold - An Integer to compare the jobs count against
    #   to consider it backed up
    #
    # Example:
    #   check = new(10, 50)
    #   # => The check will look for jobs with priority between
    #   # 0 and 10, considering the jobs as backed up if there
    #   # are more than 50 of them
    def initialize(priority, threshold)
      self.priority = Integer(priority)
      self.threshold = Integer(threshold)
    end

    # Public: Check and report whether delayed jobs are backed up
    def check
      if backed_up?
        mark_failure
        mark_message "Delayed Jobs within priority '#{priority}' backed up! (#{count})"
      else
        mark_message "Delayed Jobs within priority '#{priority}' at reasonable level (#{count})"
      end
    end

    # Public: Whether delayed jobs are backed up
    #
    # Returns a Boolean
    def backed_up?
      count > threshold
    end

    # Public: How many delayed jobs are pending within the given priority
    def count
      Delayed::Job.where("priority <= ?", priority).where(:locked_at => nil, :last_error => nil).count
    end
  end
end
