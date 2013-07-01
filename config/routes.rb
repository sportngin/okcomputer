Rails.application.routes.draw do
  get "/okcomputer" => "ok_computer#show", defaults: {check: "default"}
  get "/okcomputer/all" => "ok_computer#index"
  get "/okcomputer/:check" => "ok_computer#show"
end
