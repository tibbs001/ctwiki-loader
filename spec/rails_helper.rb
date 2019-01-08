ENV["RACK_ENV"] = "test"
ENV["RAILS_ENV"] = "test"

require File.expand_path("../../config/environment", __FILE__)

#  Define databases...
abort("WIKI_DB_SUPER_USERNAME env var must be set")   if !ENV["WIKI_DB_SUPER_USERNAME"]

#  Define info needed to deploy code to a servers with Capistrano
abort("GEM_HOME env var must be set for capistrano to deploy code to a server")         if !ENV["GEM_HOME"]
abort("GEM_PATH env var must be set for capistrano to deploy code to a server")         if !ENV["GEM_PATH"]
#abort("WIKI_PATH env var must be set for capistrano to deploy code to a server")             if !ENV["WIKI_PATH"]
#abort("LD_LIBRARY_PATH env var must be set for capistrano to deploy code to a server")  if !ENV["LD_LIBRARY_PATH"]
#abort("WIKI_DEV_DEPLOY_TO env var must be set for capistrano to deploy code to a server")    if !ENV["WIKI_DEV_DEPLOY_TO"]
##abort("WIKI_DEV_REPO_URL env var must be set for capistrano to deploy code to a server")     if !ENV["WIKI_DEV_REPO_URL"]
#abort("WIKI_DEV_SERVER env var must be set for capistrano to deploy code to a server")       if !ENV["WIKI_DEV_SERVER"]
#abort("WIKI_PROD_SSH_KEY_DIR env var must be set for capistrano to deploy code to a server")  if !ENV["WIKI_PROD_SSH_KEY_DIR"]
#abort("WIKI_SERVER_USERNAME env var must be set for capistrano to deploy code to a server")  if !ENV["WIKI_SERVER_USERNAME"]

#  Define contact info...
#abort("WIKI_ADMIN_EMAILS env var must be set to email people administering WIKI")            if !ENV["WIKI_ADMIN_EMAILS"]

require "rspec/rails"

#Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |file| require file }

module Features
  # Extend this module in spec/support/features/*.rb
  include Formulaic::Dsl
end

RSpec.configure do |config|
  config.infer_base_class_for_anonymous_controllers = false
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner[:active_record, { model: Study }].clean_with(:truncation)
  end

  config.before(:each) do |example|
    unit_test = ![:feature, :request].include?(example.metadata[:type])
    strategy = unit_test ? :transaction : :truncation

    DatabaseCleaner.strategy = strategy
    DatabaseCleaner[:active_record, { model: Study }].clean_with(:truncation)

    DatabaseCleaner.start

    # ensure app user logged into db connections
    ActiveRecord::Base.establish_connection(
      adapter: 'postgresql',
      encoding: 'utf8',
      hostname: ENV['WIKI_PUBLIC_HOSTNAME'],
      database: ENV['WIKI_DATABASE_NAME'],
      username: ENV['WIKI_DB_SUPER_USERNAME'])
    @dbconfig = YAML.load(File.read('config/database.yml'))
    ActiveRecord::Base.establish_connection @dbconfig[:test]
  end

  config.after(:each) do
    DatabaseCleaner.clean
    DatabaseCleaner[:active_record, { model: Study }].clean
  end

end

ActiveRecord::Migration.maintain_test_schema!
