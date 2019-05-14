require 'rubygems'
require 'sparql/client'

module Util
  class WikiDataManager2
    attr_accessor :property_mgr

    def initialize
      @property_mgr = Util::PropertyManager.new
    end

    def aact_values_for_property(nct_id, property_code)
      study=Study.where('nct_id=?',nct_id).first
      return [] if !study
      property_mgr.aact_values_for_property(study, property_code)
    end

    def wiki_api_call(search_string, search_strings_tried, delimiter=nil)
      if !search_strings_tried.include?(search_string)
        search_strings_tried << search_string
        if delimiter.blank?
          puts ">>>>>> using initial string: #{search_string}"
        else
          puts ">>>>>> spliting on #{delimiter}: #{search_string}"
        end
        url = "https://www.wikidata.org/w/api.php?action=wbsearchentities&search=#{search_string}&language=en&format=json"
        puts "#{url}"
        download = RestClient::Request.execute({ url: url, method: :get, content_type: :json})
        eval(download)[:search]
      end
    end

    def study_already_loaded?(nct_id)
      !qcodes_for_nct_id(nct_id).empty?
    end

    def wikidata_study_ids
      results=[]
      cmd="SELECT ?item ?nct_id WHERE { ?item p:P31/ps:P31/wdt:P279* wd:Q30612.  ?item wdt:P3098 ?nct_id . }"
      run_sparql(cmd).each {|i|
        label = val = ''
        i.each_binding { |name, item|
          label = item.value if name == :nct_id
          val   = item.value.chomp.split('/').last if name == :item
        }
        results << {label.to_s => val }
      }
      return results.flatten.uniq
    end

    def nctids_in(hash)
      keys = []
      hash.each { |entry| keys << entry.keys }
      keys.flatten
    end

    def run_sparql(cmd)
      client = SPARQL::Client.new("https://query.wikidata.org/sparql")
      return client.query(cmd)
    end

  end
end
