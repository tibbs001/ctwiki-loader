namespace :lookup do
  namespace :populate do
    task :run, [:force] => :environment do |t, args|
      Lookup::Intervention.populate
      Lookup::Condition.populate
      Lookup::Keyword.populate
      Lookup::Sponsor.populate
      Lookup::Organization.populate
    end
  end
end
