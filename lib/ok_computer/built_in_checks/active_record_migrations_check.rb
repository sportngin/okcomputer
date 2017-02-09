module OkComputer
  class ActiveRecordMigrationsCheck < Check
    # Public: Check if migrations are pending or not
    def check
      if needs_migration?
        mark_failure
        mark_message "Pending migrations"
      else
        mark_message "NO pending migrations"
      end
    end

    private

    def needs_migration?
      if ActiveRecord::Migrator.respond_to?(:needs_migration?)
        return ActiveRecord::Migrator.needs_migration?
      else
        (ActiveRecord::Migrator.migrations(ActiveRecord::Migrator.migrations_paths).collect(&:version) -
         ActiveRecord::Migrator.get_all_versions(ActiveRecord::Base.connection)).size > 0
      end
    end
  end
end
