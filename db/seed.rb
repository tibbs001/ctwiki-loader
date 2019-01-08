# Reset search_path for wiki so it can pull from ctgov schema
con=ActiveRecord::Base.connection
con.execute("alter role wiki in database aact set search_path = lookup, ctgov;")
con.reset!

Lookup::Condition.populate
Lookup::Country.populate
Lookup::Intervention.populate
Lookup::Sponsor.populate
