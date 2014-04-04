module OKComputer
  class Engine < ::Rails::Engine

    isolate_namespace OKComputer

    config.after_initialize do |app|
      OKComputer::Engine.prepend_routes(app)
    end

    config.generators do |g|
      g.test_framework :rspec, :view_specs => false
    end

    private

    # Private: Prepend routes so a catchall doesn't get in the way
    def self.prepend_routes(app)
      return if OKComputer::Engine.routes.recognize_path('/') rescue nil
      require OKComputer::Engine.root.join("app/controllers/o_k_computer/ok_computer_controller")

      app.routes.prepend do
        mount OKComputer::Engine => OKComputer.mount_at, as: "okcomputer"
      end
    end
  end
end
