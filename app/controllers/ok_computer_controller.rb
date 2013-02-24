class OkComputerController < ActionController::Base
  layout nil
  respond_to :text, :json

  before_filter :authenticate

  rescue_from OKComputer::Registry::CheckNotFound do |e|
    respond_to do |f|
      f.text { render text: e.message, status: :not_found }
      f.json { render json: { error: e.message }, status: :not_found }
    end
  end

  def index
    checks = OKComputer::Registry.all
    checks.run

    respond_with checks, status: status_code(checks)
  end

  def show
    check = OKComputer::Registry.fetch(params[:check])
    check.run

    respond_with check, status: status_code(check)
  end

  def status_code(check)
    check.success? ? :ok : :error
  end
  private :status_code

  def authenticate
    if OKComputer.requires_authentication?
      authenticate_or_request_with_http_basic do |username, password|
        OKComputer.authenticate(username, password)
      end
    end
  end
  private :authenticate
end
