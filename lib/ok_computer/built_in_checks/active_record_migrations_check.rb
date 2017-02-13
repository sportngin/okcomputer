module OkComputer
  class ActiveRecordMigrationsCheck < Check

    def initialize
      unless ActiveRecord::Migrator.respond_to?(:needs_migration?)
        fail NotImplementedError, "ActiveRecord::Migrator.needs_migration? can't be called."
        "This OkComputer check only works on ActiveRecord > 4"
      end
      super
    end

    # Public: Check if migrations are pending or not
    def check
      if ActiveRecord::Migrator.needs_migration?
        mark_failure
        mark_message "Pending migrations"
      else
        mark_message "NO pending migrations"
      end
    end

  end
end
