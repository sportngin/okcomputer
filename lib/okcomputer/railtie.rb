module OKComputer
  class Railtie < ::Rails::Railtie

    config.after_initialize do |app|
      OKComputer::Railtie.ignore_newrelic
    end

    private

    # Private: If NewRelic is installed, inject OkComputerController with logic to ignore
    # it for the purposes of NewRelic app timing
    def self.ignore_newrelic
      if defined?(NewRelic::Agent::Instrumentation::ControllerInstrumentation)
        require OKComputer::Engine.root.join('app/controllers/o_k_computer/ok_computer_controller')
        OKComputer::OkComputerController.class_eval do
          include NewRelic::Agent::Instrumentation::ControllerInstrumentation
          newrelic_ignore
        end
      end
    end
  end
end
