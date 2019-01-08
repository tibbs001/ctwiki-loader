Rake::Task["db:create"].clear
Rake::Task["db:drop"].clear
#Rake::Task["db:migrate"].clear

namespace :db do

  task create: [:environment] do
    con=ActiveRecord::Base.connection
    con.execute("CREATE SCHEMA lookup;")
    con.execute("GRANT USAGE ON ALL SEQUENCES IN SCHEMA lookup TO wiki;")
    con.execute("GRANT ALL ON ALL TABLES IN SCHEMA lookup TO wiki;")
    con.reset!
  end

  task drop: [:environment] do
    con=ActiveRecord::Base.connection
    con.execute("DROP SCHEMA lookup CASCADE;")
    con.reset!
  end

end

