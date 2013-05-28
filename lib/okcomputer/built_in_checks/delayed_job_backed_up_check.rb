module OKComputer
  class DelayedJobBackedUpCheck < SizeThresholdCheck
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
      self.name = "Delayed Jobs within priority '#{priority}'"
    end

    # Public: How many delayed jobs are pending within the given priority
    def size
      Delayed::Job.where("priority <= ?", priority).where(:locked_at => nil, :last_error => nil).count
    end
  end
end
