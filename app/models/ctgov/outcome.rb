module Ctgov
  class Outcome < Ctgov::StudyRelationship
    has_many :outcome_counts, inverse_of: :outcome, autosave: true
    has_many :outcome_analyses, inverse_of: :outcome, autosave: true
    has_many :outcome_measurements, inverse_of: :outcome, autosave: true

    def analyses
      outcome_analyses
    end

  end
end
