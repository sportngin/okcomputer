Rails.application.routes.draw do
  match "/okcomputer" => "ok_computer#show", defaults: {check: "default", format: "text"}
  match "/okcomputer/all(.:format)" => "ok_computer#index", defaults: {format: "text"}
  match "/okcomputer/(:check)(.:format)" => "ok_computer#show", defaults: {format: "text"}
end
