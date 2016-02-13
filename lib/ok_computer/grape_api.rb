require "ok_computer/registry"

module OkComputer
  class GrapeApi < Grape::API

    content_type :json, 'application/json'
    content_type :txt, 'text/plain'
    content_type :html, 'text/html'

    formatter :json, ->(object, env){ object.to_json }
    formatter :txt, ->(object, env){ object.to_text }
    formatter :html, ->(object, env){ object.to_text }

    error_formatter :json, ->(message, backtrace, options, env) { { error: message.to_s }.to_json }
    error_formatter :txt, ->(message, backtrace, options, env) { message }
    error_formatter :html, ->(message, backtrace, options, env) { message }

    rescue_from OkComputer::Registry::CheckNotFound do |exception|
      error!(exception, 404)
    end

    helpers do
      def status_code(check)
        check.success? ? 200 : 500
      end
    end

    before do
      if OkComputer.analytics_ignore && defined?(NewRelic::Agent)
        NewRelic::Agent.ignore_transaction
      end
    end

    desc 'Perform a simple up check'
    get do
      checks = OkComputer::Registry.all
      checks.run

      status status_code(checks)
      checks
    end

    desc 'Perform all installed checks'
    get :all do
    end

    route_param :check do
      desc 'Perform a specific installed check'
      get do
        check = OkComputer::Registry.fetch(params[:check])
        check.run

        status status_code(check)
        check
      end
    end

  end
end
