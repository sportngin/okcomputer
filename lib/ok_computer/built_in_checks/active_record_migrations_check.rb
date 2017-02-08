module OkComputer
  class ActiveRecordMigrationsCheck < Check
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
