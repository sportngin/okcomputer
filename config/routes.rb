OKComputer::Engine.routes.draw do
  match "/" => "ok_computer#show", defaults: {check: "default", format: "text"}
  match "/all(.:format)" => "ok_computer#index", defaults: {format: "text"}
  match "/(:check)(.:format)" => "ok_computer#show", defaults: {format: "text"}
end
