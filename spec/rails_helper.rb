ENV["RACK_ENV"] = "test"
ENV["RAILS_ENV"] = "test"

require File.expand_path("../../config/environment", __FILE__)

#  Define databases...
abort("WIKI_DB_SUPER_USERNAME env var must be set")   if !ENV["WIKI_DB_SUPER_USERNAME"]

require "rspec/rails"

Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |file| require file }

RSpec.configure do |config|
  config.infer_base_class_for_anonymous_controllers = false
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner[:active_record, { model: Wikidata::Publication }].clean_with(:truncation)
  end

  config.before(:each) do |example|
    unit_test = ![:feature, :request].include?(example.metadata[:type])
    strategy = unit_test ? :transaction : :truncation

    DatabaseCleaner.strategy = strategy
    DatabaseCleaner[:active_record, { model: Wikidata::Publication }].clean_with(:truncation)

    #DatabaseCleaner.start

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
    DatabaseCleaner[:active_record, { model: Wikidata::Publication }].clean
  end

end

ActiveRecord::Migration.maintain_test_schema!
