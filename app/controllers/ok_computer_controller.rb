class OkComputerController < ApplicationController
  layout nil
  respond_to :text, :json

  def index
    checks = OKComputer::Registry.registered_checks

    respond_with checks
  end

  def show
    check = OKComputer::Registry.fetch(params[:check])

    respond_with check
  end
end
