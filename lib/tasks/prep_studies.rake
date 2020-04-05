namespace :prep do
  # bundle exec rake quickstatement:extract[60000]
  # Iterates thru Studies (starting at study # 60,000) in batches of 2,000
  # Creates a file in public dir for each batch that can then be imported
  # into wiki data via quickstatement site:  https://tools.wmflabs.org/quickstatements/
  # Or the files can be sent to wikidata with a command like:
  #
  #   curl https://tools.wmflabs.org/quickstatements/api.php -d action=import \
  #   -d submit=1 -d 'batchname=Clinical Trials - start at 1'  -d 'username=Tibbs001' \
  #   -d 'token=' \
  #   --data-urlencode data@2000_study_quickstatements.txt

  task :studies, [:start_num] => :environment do |t, args|
    if args[:start_num]
      Util::StudyPrepper.new({:start_num=>'0'}).run
    else
      Util::StudyPrepper.new.run
    end
  end
end
