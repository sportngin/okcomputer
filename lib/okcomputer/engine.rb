module OKComputer
  class Engine < ::Rails::Engine

    isolate_namespace OKComputer

    config.after_initialize do |app|
      OKComputer::Engine.prepend_routes(app)
      OKComputer::Engine.ignore_newrelic
    end

    config.generators do |g|
      g.test_framework :rspec, :view_specs => false
    end

    private

    # Private: Prepend OKComputer routes so a catchall doesn't get in the way
    def self.prepend_routes(app)
      return if OKComputer::Engine.routes.recognize_path('/') rescue nil
      require OKComputer::Engine.root.join("app/controllers/o_k_computer/ok_computer_controller")

      app.routes.prepend do
        mount OKComputer::Engine => OKComputer.mount_at, as: "okcomputer"
      end
    end

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
