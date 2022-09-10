require File.expand_path('../boot', __FILE__)
require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"

Bundler.require(*Rails.groups)
module AACT
  class Application < Rails::Application
    config.time_zone = 'Eastern Time (US & Canada)'
    config.generators do |generate|
      generate.helper false
    end
    config.active_record.schema_format = :sql
  end
end
