Rake::Task["db:create"].clear
Rake::Task["db:drop"].clear
#Rake::Task["db:migrate"].clear

namespace :db do

  task create: [:environment] do
    con=ActiveRecord::Base.connection
    con.execute("CREATE SCHEMA lookup;")
    con.execute("CREATE SCHEMA pubmed;")
    con.execute("GRANT USAGE ON ALL SEQUENCES IN SCHEMA lookup TO  #{ENV['AACT_DB_SUPER_USERNAME']};")
    con.execute("GRANT USAGE ON ALL SEQUENCES IN SCHEMA pubmed TO  #{ENV['AACT_DB_SUPER_USERNAME']};")
    con.execute("GRANT USAGE ON ALL SEQUENCES IN SCHEMA lookup TO  #{ENV['WIKI_DB_SUPER_USERNAME']};")
    con.execute("GRANT USAGE ON ALL SEQUENCES IN SCHEMA pubmed TO  #{ENV['WIKI_DB_SUPER_USERNAME']};")
    con.execute("GRANT ALL ON ALL TABLES IN SCHEMA lookup TO #{ENV['AACT_DB_SUPER_USERNAME']};")
    con.execute("GRANT ALL ON ALL TABLES IN SCHEMA pubmed TO #{ENV['AACT_DB_SUPER_USERNAME']};")
    con.execute("GRANT ALL ON ALL TABLES IN SCHEMA lookup TO #{ENV['WIKI_DB_SUPER_USERNAME']};")
    con.execute("GRANT ALL ON ALL TABLES IN SCHEMA pubmed TO #{ENV['WIKI_DB_SUPER_USERNAME']};")
    con.execute("alter role #{ENV['AACT_DB_SUPER_USERNAME']} in database open_trials set search_path to pubmed, lookup, ctgov, proj_cdek_standard_orgs, proj_tag_nephrology;")
    con.execute("alter role #{ENV['WIKI_DB_SUPER_USERNAME']} in database open_trials set search_path to pubmed, lookup, ctgov, proj_cdek_standard_orgs, proj_tag_nephrology;")
    con.reset!
  end

  task drop: [:environment] do
    con=ActiveRecord::Base.connection
    con.execute("DROP SCHEMA lookup CASCADE;")
    con.execute("DROP SCHEMA pubmed CASCADE;")
    con.reset!
  end

end

