namespace :lookup do
  #   bundle exec rake lookup:populate['Intervention']
    task :populate, [:model] => :environment do |t, args|
      if args[:model]
        lookup_table = "Lookup::#{args[:model]}".constantize
        lookup_table.populate
      else
        Lookup::Intervention.populate
        Lookup::Condition.populate
        Lookup::Keyword.populate
        Lookup::Sponsor.populate
        Lookup::Organization.populate
      end
  end
end
