module Ctgov
  class ReportedEvent < Ctgov::StudyRelationship
    belongs_to :result_group
  end
end
