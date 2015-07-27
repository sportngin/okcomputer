class Module
  def mattr_reader(*syms)
    syms.each do |sym|
      next if sym.is_a?(Hash)
      class_eval(<<-EOS, __FILE__, __LINE__)
        unless defined? @@#{sym}
          @@#{sym} = nil
        end

        def self.#{sym}
          @@#{sym}
        end
        def #{sym}
          @@#{sym}
        end
      EOS
    end
  end

  def mattr_writer(*syms)
    options = syms.extract_options!
    syms.each do |sym|
      class_eval(<<-EOS, __FILE__, __LINE__)
        unless defined? @@#{sym}
          @@#{sym} = nil
        end

        def self.#{sym}=(obj)
          @@#{sym} = obj
        end

        #{"
        def #{sym}=(obj)
          @@#{sym} = obj
        end
        " unless options[:instance_writer] == false }
      EOS
    end
  end

  def mattr_accessor(*syms)
    mattr_reader(*syms)
    mattr_writer(*syms)
  end
end
require "ok_computer/configuration"
require "ok_computer/check"
require "ok_computer/check_collection"
require "ok_computer/registry"

# and the built-in checks
require "ok_computer/built_in_checks/size_threshold_check"
require "ok_computer/built_in_checks/http_check"

require "ok_computer/built_in_checks/active_record_check"
require "ok_computer/built_in_checks/app_version_check"
require "ok_computer/built_in_checks/cache_check"
require "ok_computer/built_in_checks/default_check"
require "ok_computer/built_in_checks/delayed_job_backed_up_check"
require "ok_computer/built_in_checks/generic_cache_check"
require "ok_computer/built_in_checks/elasticsearch_check"
require "ok_computer/built_in_checks/solr_check"
require "ok_computer/built_in_checks/mongoid_check"
require "ok_computer/built_in_checks/mongoid_replica_set_check"
require "ok_computer/built_in_checks/resque_backed_up_check"
require "ok_computer/built_in_checks/resque_down_check"
require "ok_computer/built_in_checks/resque_failure_threshold_check"
require "ok_computer/built_in_checks/ruby_version_check"
require "ok_computer/built_in_checks/sidekiq_latency_check"

OkComputer::Registry.register "default", OkComputer::DefaultCheck.new
OkComputer::Registry.register "database", OkComputer::ActiveRecordCheck.new
