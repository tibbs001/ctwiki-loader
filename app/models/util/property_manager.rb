module Util
  class PropertyManager

    def property_map
     {
       'P1813' => [:acronym],
       'P2175' => [:browse_conditions, :downcase_mesh_term],
       'P1050' => [:conditions, :qcode],
       'P17'   => [:countries, :name],
       'P1476' => [:design, :intervention_for_wikidata],
       'P1132' => [:enrollemnt],
       'P6153' => [:facilities, :qcode],
       'P3098' => [:nct_id],
       'P1476' => [:official_title],
       'P6099' => [:phase_for_wikidata],
       'P582'  => [:primary_completion_date],
       'P859'  => [:sponsors, :qcode],
       'P580'  => [:start_date],
     }
    end

    def aact_values_for_property(study, code)
      # For now, assume there can only be 1 or 2 methods to get to the values
      # For consistency, return an array even if there's only one value
      methods = property_map[code]
      if methods.nil?
        puts "WARNING:  Property #{code} not found."
        return []
      end
      return [study.send(methods.first)] if methods.size == 1
      return study.send(methods.first).pluck(methods.last).uniq
    end

  end
end

