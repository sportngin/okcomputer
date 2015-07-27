class Hash
  # By default, only instances of Hash itself are extractable.
  # Subclasses of Hash may implement this method and return
  # true to declare themselves as extractable. If a Hash
  # is extractable, Array#extract_options! pops it from
  # the Array when it is the last element of the Array.
  def extractable_options?
    instance_of?(Hash)
  end
end

class Array
  # Extracts options from a set of arguments. Removes and returns the last
  # element in the array if it's a hash, otherwise returns a blank hash.
  #
  #   def options(*args)
  #     args.extract_options!
  #   end
  #
  #   options(1, 2)        # => {}
  #   options(1, 2, a: :b) # => {:a=>:b}
  def extract_options!
    if last.is_a?(Hash) && last.extractable_options?
      pop
    else
      {}
    end
  end
end
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
require "ok_computer/built_in_checks/default_check"
require "ok_computer/built_in_checks/delayed_job_backed_up_check"
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
