module Ctgov
  class OutcomeMeasurement < Ctgov::StudyRelationship
    belongs_to :outcome, autosave: true
    belongs_to :result_group, autosave: true

  end
end
