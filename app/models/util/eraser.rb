module Util
  class Eraser

    attr_accessor :wiki_mgr

    def erase_study_prop(code)
      nct_ids = wiki_mgr.ids_for_studies_with_prop(code, 'nct_id')
      erase_prop_for(nct_ids, code)
    end

    def erase_prop_for(nct_ids, code)
      #nct_ids=['NCT03215810','NCT01369251']
      #property_code='P2175'
      File.open("public/erase.txt", "w+") do |f|
        nct_ids.each{ |nct_id| f << create_erase_commands(nct_id, code) }
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
          values.each {|val| lines << "||-#{qcode}|#{property_code}|\"#{val}\"" }
        }
      end
      return lines
    end

  end
end
