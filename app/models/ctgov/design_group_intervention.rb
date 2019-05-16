class DesignGroupIntervention < StudyRelationship
  belongs_to :intervention, inverse_of: :design_group_interventions, autosave: true
  belongs_to :design_group, inverse_of: :design_group_interventions, autosave: true

end
