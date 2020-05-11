namespace :refresh do

  task recruitment_status: [:environment] do |t, args|
    Util::StudyPrepper.new.refresh_prop('P8005')
  end

end
