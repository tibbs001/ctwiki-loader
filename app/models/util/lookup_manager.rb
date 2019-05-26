module Util
  class LookupManager

    attr_accessor :countries, :orgs, :pubs_not_in_wikidata

    def initialize
      load_countries
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

  end
end
