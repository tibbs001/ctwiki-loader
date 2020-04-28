module Util
  class WikiStudyManager < Util::WikiDataManager

    def get_study_id_maps
      results={}
      cmd="SELECT ?item ?nct_id WHERE { ?item p:P31/ps:P31/wdt:P279* wd:Q30612.  ?item wdt:P3098 ?nct_id . }"
      query_results = run_sparql(cmd)
      query_results.each {|i|
        label = val = ''
        i.each_binding { |name, item|
          label = item.value if name == :nct_id
          val   = item.value.chomp.split('/').last if name == :item
        }
        results[label.to_s] = val
      }
      return results
    end

    def study_already_loaded?(nct_id)
      !qcodes_for_nct_id(nct_id).empty?
    end

    def get_qcode_for_orcid(orcid)
      #cmd = "SELECT DISTINCT  ?item WHERE { ?item p:P31/ps:P31/wdt:P279* wd:Q191067 . ?item wdt:P698 '#{pmid}'. }"
      cmd = "SELECT DISTINCT  ?item where { ?item wdt:P496 '#{orcid}' }"
      results = run_sparql(cmd)
      return nil if results.empty?
      the_code=nil
      results.first.each_binding {|item| the_code = item.last.value.chomp.split('/').last }
      return the_code
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

    def info_for_studies_with_prop(code)
      # phase is P6099
      result = []
      cmd="SELECT ?item ?nct_id ?subj WHERE {
           ?item p:P31/ps:P31/wdt:P279* wd:Q30612.
           ?item wdt:#{code} ?subj .
           ?item wdt:P3098   ?nct_id }"
      run_sparql(cmd).each {|i|
        nct_id = qcode = subj = ''
        i.each_binding { |name, item|
          nct_id = item.value if name == :nct_id
          qcode  = item.value.chomp.split('/').last if name == :item
          subj   = item.value.chomp.split('/').last if name == :subj
        }
        result << {nct_id.to_s => [qcode, subj] }
      }
      return result.flatten.uniq
    end

    def ids_for_studies_without_prop(code)
      # phase is P6099
      result = []
      cmd="SELECT ?item ?nct_id WHERE {
           ?item p:P31/ps:P31/wdt:P279* wd:Q30612.
           FILTER NOT EXISTS {?item wdt:#{code} ?phase}
             ?item wdt:P3098 ?nct_id .  }"
      result = []
      run_sparql(cmd).each {|i|
        label = val = ''
        i.each_binding { |name, item|
          label = item.value if name == :nct_id
          val   = item.value.chomp.split('/').last if name == :item
        }
        result << {label.to_s => val }
      }
      return result.flatten.uniq
    end

    def qcodes_for_nct_id(nct_id)
      #existing_nct_id='NCT02856984'
      cmd = "SELECT ?item WHERE { ?item wdt:P3098 '#{nct_id}' . } "
      result = []
      run_sparql(cmd).each {|i|
        i.each_binding { |name, item| result << item.value.chomp.split('/').last } if !i.blank?
      }
      return result.flatten
    end

  end
end
