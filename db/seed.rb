# Reset search_path for wiki so it can pull from ctgov schema
con=ActiveRecord::Base.connection
con.execute("alter role wiki in database open_trials set search_path = lookup, ctgov, support;")
con.reset!

Lookup::Condition.populate
Lookup::Country.populate
Lookup::Intervention.populate
Lookup::Sponsor.populate
