module Util
  class LookupManager

    attr_accessor :authors, :countries, :orgs, :studies, :publications, :pubs_not_in_wikidata

    def initialize
      load_authors
      load_countries
      load_publications
      load_studies
      load_orgs
    end

    def load_authors
      @authors={}
      Lookup::Author.all.pluck(:downcase_name, :qcode).each {|c|
        @authors[c.first] = c.last
      }
      @authors.compact!
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
      @publications = Util::WikiPubManager.new.get_pub_id_maps
    end

    def load_studies
      @studies = Util::WikiStudyManager.new.get_study_id_maps
    end

  end
end
