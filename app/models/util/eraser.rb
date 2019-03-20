module Util
  class Eraser

    attr_accessor :wiki_mgr

    def erase_prop(code)
      erase_props_for(wiki_mgr.get_vals_for(code))
    end

    def erase_props_for(ids_and_vals)
      # expect ids_and_vals to be a collection of arrays like: [qcode, nct_id, prop_code, val]
      File.open("public/erase_#{ids_and_vals.first[2]}.txt", "w+") do |f|
        ids_and_vals.each{ |array| f << "\n-#{array.first}\t#{array[2]}\t#{array.last}" }
      end
    end

    def initialize
      @wiki_mgr=Util::WikiDataManager.new
    end

    def create_erase_commands(nct_id, property_code)
      lines=''
      qcodes=wiki_mgr.qcodes_for_nct_id(nct_id)
      if !qcodes.empty?
        qcodes.each{|qcode|
          # get value from AACT, not wikidata so we don't erase something we didn't create
          # TODO:  prob is, values can change in AACT too.  How to handle that?
          values = wiki_mgr.aact_values_for_property(nct_id, property_code)
          values.each {|val| lines << "-#{qcode}|#{property_code}|#{val}" }
        }
      end
      return lines
    end

  end
end
