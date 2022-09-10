Rails.application.configure do
  host = ENV.fetch("APPLICATION_HOST",'localhost')
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local       = true
  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load
  config.action_view.raise_on_missing_translations = true
end
