# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

#GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA lookup TO wiki;
#GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA pubmed TO wiki;
Rails.application.load_tasks
task(:default).clear
task default: [:spec]

