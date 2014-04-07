OKComputer::Engine.routes.draw do
  root to: "ok_computer#show", defaults: {check: "default"}, via: [:get, :options]
  match "/all" => "ok_computer#index", via: [:get, :options]
  match "/:check" => "ok_computer#show", via: [:get, :options]
end

if OKComputer.mount_at
  # prepend sets at a higher priority than "catchall" routes
  Rails.application.routes.prepend do
    mount OKComputer::Engine => OKComputer.mount_at, as: "okcomputer"
  end
end
