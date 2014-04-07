require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require
require "okcomputer"

module Dummy
  class Application < Rails::Application
    config.encoding = "utf-8"
    config.filter_parameters += [:password]
    config.active_support.escape_html_entities_in_json = true
    config.assets.enabled = false
    config.secret_token = 'paranoidandroidsubterraneanhomesickalien'
    config.secret_key_base = 'fitterhappiermoreproductive'
    config.session_store :cookie_store, key: '_dummy_session'
    config.cache_classes = true
    config.serve_static_assets = false
    config.static_cache_control = "public, max-age=3600"
    config.consider_all_requests_local       = true
    config.action_controller.perform_caching = false
    config.action_dispatch.show_exceptions = false
    config.action_controller.allow_forgery_protection    = false
    config.action_mailer.delivery_method = :test
    config.active_support.deprecation = :stderr
    config.eager_load = false
  end
end
