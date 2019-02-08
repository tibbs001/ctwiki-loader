module Util
  class PropertyManager

    def property_map
     {
       'P2175' => [:browse_conditions, :downcase_mesh_term],
       'P17'   => [:countries, :name],
     }
    end

    def aact_values_for_property(study, code)
      # For now, assume there can only be 1 or 2 methods to get to the values
      # For consistency, return an array even if there's only one value
      methods = property_map[code]
      return [study.send(methods.first)] if methods.size == 1
      return study.send(methods.first).pluck(methods.last).uniq
    end

  end
end

