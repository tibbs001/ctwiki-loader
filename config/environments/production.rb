Rails.application.configure do
  host = ENV.fetch("APPLICATION_HOST",'localhost')
  config.cache_classes = true
  config.eager_load = false
  config.consider_all_requests_local       = false
  config.log_level = :debug
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.active_record.dump_schema_after_migration = false
end
