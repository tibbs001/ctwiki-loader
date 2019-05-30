module Ctgov
  class BrowseCondition < Ctgov::StudyRelationship
    self.table_name = 'ctgov.browse_conditions'

    def name
      mesh_term
    end

  end
end
