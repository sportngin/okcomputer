Rails.application.routes.draw do
  match "/okcomputer" => "ok_computer#show", defaults: {check: "default"}
  match "/okcomputer/all" => "ok_computer#index"
  match "/okcomputer/:check" => "ok_computer#show"
end
