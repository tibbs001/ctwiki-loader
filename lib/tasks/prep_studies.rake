namespace :prep do
  # bundle exec rake prep:studies[60000]
  # Iterates thru Studies (starting at study # 60,000) in batches of 2,000
  # Creates a file in public dir for each batch that can then be imported
  # into wiki data via quickstatement site:  https://tools.wmflabs.org/quickstatements/

  task :studies, [:start_num] => :environment do |t, args|
    if args[:start_num]
      Util::StudyPrepper.new({:start_num=> args[:start_num]}).run
    else
      Util::StudyPrepper.new.run
    end
  end

end
