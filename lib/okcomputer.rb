require "okcomputer/engine"
require "okcomputer/configuration"
require "okcomputer/check"
require "okcomputer/check_collection"
require "okcomputer/registry"

# and the built-in checks
require "okcomputer/built_in_checks/size_threshold_check"
require "okcomputer/built_in_checks/active_record_check"
require "okcomputer/built_in_checks/default_check"
require "okcomputer/built_in_checks/mongoid_check"
require "okcomputer/built_in_checks/resque_backed_up_check"
require "okcomputer/built_in_checks/resque_down_check"
require "okcomputer/built_in_checks/delayed_job_backed_up_check"

module OKComputer
end

OKComputer::Registry.register "default", OKComputer::DefaultCheck.new
OKComputer::Registry.register "database", OKComputer::ActiveRecordCheck.new

