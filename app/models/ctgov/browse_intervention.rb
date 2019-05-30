module Ctgov
  class BrowseIntervention < Ctgov::StudyRelationship
    self.table_name = 'ctgov.browse_interventions'

    def name
      mesh_term
    end
  end

end
