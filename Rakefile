# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks
task(:default).clear
task default: [:spec]

namespace :db do
  def set_search_path
    puts "Setting search path to lookup only..."
    con=ActiveRecord::Base.connection
    con.execute("create schema wikidata;")
    con.execute("create schema lookup;")
    con.execute("alter role #{ENV['WIKI_DB_SUPER_USERNAME']} IN DATABASE aact set search_path to lookup, wikidata, ctgov;")
    con.reset!
  end

  task :after_set_search_path do
    at_exit { set_search_path }
  end

end

Rake::Task['db:create'].enhance(['db:after_set_search_path'])
