module Ctgov
  class Reference < Ctgov::StudyRelationship
    self.table_name='ctgov.study_references'

    def type
      reference_type
    end

  end
end
