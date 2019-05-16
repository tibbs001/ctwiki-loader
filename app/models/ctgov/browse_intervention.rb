module Ctgov
  class BrowseIntervention < StudyRelationship
    self.table_name = 'ctgov.browse_interventions'

    def name
      mesh_term
    end
  end

end
