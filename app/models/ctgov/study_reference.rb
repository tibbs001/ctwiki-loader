module Ctgov
  class StudyReference < Ctgov::StudyRelationship
    self.table_name = 'ctgov.study_references'

    def type
      reference_type
    end
  end
end
