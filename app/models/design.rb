class Design < StudyRelationship

  def intervention_for_wikidata
    new_line=>'
'
    "#{intervention_model_description.gsub('#{new_line}','~')}"
  end

end
