Rake::Task["db:create"].clear
Rake::Task["db:drop"].clear
#Rake::Task["db:migrate"].clear

namespace :db do

  task create: [:environment] do
    con=ActiveRecord::Base.connection
    con.execute("CREATE SCHEMA lookup;")
    con.execute("CREATE SCHEMA pubmed;")
    con.execute("CREATE SCHEMA nci;")
    con.execute("GRANT USAGE ON ALL SEQUENCES IN SCHEMA lookup TO wiki;")
    con.execute("GRANT USAGE ON ALL SEQUENCES IN SCHEMA pubmed TO wiki;")
    con.execute("GRANT USAGE ON ALL SEQUENCES IN SCHEMA nci TO wiki;")
    con.execute("GRANT ALL ON ALL TABLES IN SCHEMA lookup TO wiki;")
    con.execute("GRANT ALL ON ALL TABLES IN SCHEMA pubmed TO wiki;")
    con.execute("GRANT ALL ON ALL TABLES IN SCHEMA nci TO wiki;")
    con.execute("alter role #{ENV['WIKI_DB_SUPER_USERNAME']} in database aact set search_path to pubmed, lookup, ctgov, nci, proj_cdek_standard_orgs, proj_tag_nephrology;")
    con.execute("alter role #{ENV['WIKI_DB_SUPER_USERNAME']} in database aact_back_test set search_path to pubmed, lookup, ctgov, nci, proj_cdek_standard_orgs, proj_tag_nephrology;")
    con.reset!
  end

  task drop: [:environment] do
    con=ActiveRecord::Base.connection
    con.execute("DROP SCHEMA lookup CASCADE;")
    con.execute("DROP SCHEMA pubmed CASCADE;")
    con.execute("DROP SCHEMA nci CASCADE;")
    con.reset!
  end

end

