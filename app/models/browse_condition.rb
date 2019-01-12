class BrowseCondition < StudyRelationship
  self.table_name = 'ctgov.browse_conditions'

  def name
    mesh_term
  end

end
