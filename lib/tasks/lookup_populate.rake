namespace :lookup do
  namespace :populate do
    task :run, [:force] => :environment do |t, args|
      Lookup::Intervention.populate
      Lookup::Condition.populate
    end
  end
end
