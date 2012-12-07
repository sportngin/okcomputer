class OkComputerController < ActionController::Base
  layout nil
  respond_to :text, :json

  def index
    checks = OKComputer::Registry.all

    respond_with checks, status: status_code(checks)
  end

  def show
    check = OKComputer::Registry.fetch(params[:check])

    respond_with check, status: status_code(check)
  end

  def status_code(check)
    check.success? ? :ok : :error
  end
  private :status_code
end
