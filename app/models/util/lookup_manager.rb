module Util
  class LookupManager

    attr_accessor :countries, :orgs, :studies, :publications, :pubs_not_in_wikidata

    def initialize
      load_countries
      load_publications
      load_studies
#      load_orgs
    end

    def load_countries
      @countries={}
      Lookup::Country.all.pluck(:downcase_name, :qcode).each {|c|
        @countries[c.first] = c.last
      }
    end

    def load_orgs
      @orgs={}
      Lookup::Organization.all.pluck(:downcase_name, :qcode).each {|c|
        @orgs[c.first] = c.last
      }
    end

    def load_pubs_not_in_wikidata
      @pubs_not_in_wikidata = {}
      Lookup::Publication.where('qcode is null').pluck(:downcase_name, :qcode).each {|c|
        @orgs[c.first] = c.last
      }
    end

    def load_publications
      @publications = Util::WikiDataManager.new.get_pub_id_maps
    end

    def load_studies
      @studies = Util::WikiDataManager.new.get_study_id_maps
    end

  end
end
