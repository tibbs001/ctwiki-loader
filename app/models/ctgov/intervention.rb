module Ctgov
  class Intervention < Ctgov::StudyRelationship
    self.table_name = 'ctgov.interventions'
    has_many :intervention_other_names, inverse_of: :intervention, autosave: true
    has_many :design_group_interventions,  inverse_of: :intervention, autosave: true
    has_many :design_groups, :through => :design_group_interventions

  end
end
