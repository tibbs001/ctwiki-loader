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

  config.before(:each) do |example|

    #unit_test = ![:feature, :request].include?(example.metadata[:type])
    #strategy = unit_test ? :transaction
    #strategy = unit_test ? :transaction : :truncation
    allow_any_instance_of(Util::StudyPrepper).to receive(:id_qcode_maps).and_return({})
    allow_any_instance_of(Util::PubPrepper).to receive(:id_qcode_maps).and_return({})
    allow_any_instance_of(Util::LookupManager).to receive(:load_studies).and_return([])
    allow(Util::Prepper).to receive(:sleep).and_return(nil)

    #DatabaseCleaner.strategy = strategy
    begin
      #DatabaseCleaner[:active_record, { model: Pubmed::Publication }].clean_with(:truncation)
    rescue
      next
    end

    DatabaseCleaner.start

  end

end

#ActiveRecord::Migration.maintain_test_schema!
