Rails.application.configure do

  ENV["AACT_ADMIN_DATABASE_URL"] = 'postgres://localhost:5432/aact_test'
  ENV["AACT_BACK_DATABASE_URL"] = 'postgres://localhost:5432/aact_test'
  config.eager_load = false
  config.serve_static_files   = true
  config.consider_all_requests_local       = true
  config.action_dispatch.show_exceptions = false
  config.active_support.test_order = :random
  config.active_support.deprecation = :stderr
end
