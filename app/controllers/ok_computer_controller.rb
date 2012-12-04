class OkComputerController < ApplicationController
  layout nil
  respond_to :text, :json

  def index
    checks = OKComputer.registered_checks

    respond_with checks
  end

  def show
    check = OKComputer.registered_check(params[:check])

    respond_with check
  end
end
