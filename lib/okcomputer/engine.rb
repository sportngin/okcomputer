module OKComputer
  class Engine < ::Rails::Engine

    isolate_namespace OKComputer

    config.after_initialize do |app|
      OKComputer::Engine.ignore_newrelic
    end

    config.generators do |g|
      g.test_framework :rspec, :view_specs => false
    end

    private

    # Private: If NewRelic is installed, inject OkComputerController with logic to ignore
    # it for the purposes of NewRelic app timing
    def self.ignore_newrelic
      if defined?(NewRelic::Agent::Instrumentation::ControllerInstrumentation)
        OKComputer::OkComputerController.class_eval do
          include NewRelic::Agent::Instrumentation::ControllerInstrumentation
          newrelic_ignore
        end
      end
    end
  end
end
