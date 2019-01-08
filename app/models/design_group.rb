class DesignGroup < StudyRelationship
  has_many :design_group_interventions,  inverse_of: :design_group, autosave: true
  has_many :interventions, :through => :design_group_interventions

end
