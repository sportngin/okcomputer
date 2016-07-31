module OkComputer
  class OkComputerController < ActionController::Base
    layout nil

    # before_filter :authenticate
    before_action :render_message, unless: :check_header

    if OkComputer.analytics_ignore && defined?(NewRelic::Agent::Instrumentation::ControllerInstrumentation)
      include NewRelic::Agent::Instrumentation::ControllerInstrumentation
      newrelic_ignore if respond_to?(:newrelic_ignore)
    end

    rescue_from OkComputer::Registry::CheckNotFound do |e|
      respond_to do |f|
        f.any(:text, :html) { render text: e.message, status: :not_found }
        f.json { render json: { error: e.message }, status: :not_found }
      end
    end

    def check_header
      request.headers["Healthcheck-Token"] == ENV['HEALTHCHECK_TOKEN']
    end

    def render_message
      checks = OkComputer::Registry.all
      checks.run
      
      render json: { stataus: checks.success? ? 'ok' : 'fail'}
    end

    def overall

    end

    def index
      checks = OkComputer::Registry.all
      checks.run

      respond checks, status_code(checks)
    end

    def show
      check = OkComputer::Registry.fetch(params[:check])
      check.run

      respond check, status_code(check)
    end

  private

    def respond(data, status)
      respond_to do |format|
         format.any(:text, :html) { render json: data, status: status }
         format.json { render json: data, status: status }
      end
    end

    def status_code(check)
      check.success? ? :ok : :error
    end

    # def authenticate
    #   if OkComputer.requires_authentication?(params)
    #     authenticate_or_request_with_http_basic do |username, password|
    #       OkComputer.authenticate(username, password)
    #     end
    #   end
    # end
  end
end
