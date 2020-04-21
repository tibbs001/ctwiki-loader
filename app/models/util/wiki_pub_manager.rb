module Util
  class WikiPubManager < WikiDataManager

    def get_pub_id_maps
      # because there are millions of scholarly articles in wikidata, we will only get the ones specifically referenced by
      # studies in ClinicalTrials.gov.  Lookup::Publication has iterated over all pmids specified in StudyReference
      # and defined the qcodes for those that are already in wikidata. Rows in Lookup::Publication without a qcode
      # represent publications that are referenced in ct.gov but aren't yet in wikidata
      results = {}
      Lookup::Publication.where('qcode is not null').pluck(:pmid, :qcode).each {|a|
        results[a.first] = a.last
      }
      return results
    end

    def get_qcode_for_pmid(pmid)
      cmd = "SELECT DISTINCT  ?item WHERE { ?item p:P31/ps:P31/wdt:P279* wd:Q191067 . ?item wdt:P698 '#{pmid}'. }"
      #cmd = "SELECT DISTINCT ?item WHERE { ?item p:P31/ps:P31/wdt:P279* wd:Q191067 . ?item wdt:P698 '23153596'. }" sample of one in wikidata
      results = run_sparql(cmd)
      return nil if results.empty?
      the_code=nil
      results.first.each_binding {|item| the_code = item.last.value.chomp.split('/').last }
      return the_code
    end

  end
end
