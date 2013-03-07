class OkComputerController < ActionController::Base
  layout nil
  respond_to :text, :html, :json

  before_filter :authenticate

  rescue_from OKComputer::Registry::CheckNotFound do |e|
    respond_to do |f|
      f.any(:text, :html) { render text: e.message, status: :not_found }
      f.json { render json: { error: e.message }, status: :not_found }
    end
  end

  def index
    checks = OKComputer::Registry.all
    checks.run

    respond checks, status_code(checks)
  end

  def show
    check = OKComputer::Registry.fetch(params[:check])
    check.run

    respond check, status_code(check)
  end

private

  def respond(data, status)
    respond_to do |format|
       format.any(:text, :html) { render text: data, status: status }
       format.json { render json: data, status: status }
    end
  end

  def status_code(check)
    check.success? ? :ok : :error
  end

  def authenticate
    if OKComputer.requires_authentication?
      authenticate_or_request_with_http_basic do |username, password|
        OKComputer.authenticate(username, password)
      end
    end
  end
end
