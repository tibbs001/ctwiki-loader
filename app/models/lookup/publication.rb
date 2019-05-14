module Lookup
  class Publication < SuperLookup
    self.table_name = 'lookup.publications'

    def self.populate
      # We will need to run this in many iterations because the sparql query endpoint seems to have a limit
      # After getting the qcode for about 100 publications, it will lock us out.  So we'll need to restart
      new.populate
    end

    def self.qcode_for(pmid)
      return if pmid.nil?
      results = self.where('qcode is not null and pmid = ?',pmid)
      return results.first.qcode if results.size > 0
    end

    def populate
      mgr = Util::WikiDataManager.new
      existing_qcodes = where('qcode is not null')
      StudyReference.where('pmid is not null').each {|ref|
        qcode = mgr.get_qcode_for_pmid(ref.pmid)
        if !existing_qcodes.include? qcode
          begin
            Lookup::Publication.new(
              :qcode         => qcode,
              :name          => ref.study.name,
              :downcase_name => name.try(:downcase),
              :pmid          => ref.pmid,
            ).save!
          rescue => error
            puts "#{Time.zone.now}: Unable to populate publications_lookup.  #{error.message}"
          end
          existing_qcodes << qcode
        end
      }
    end

    def wikidata_entities
      #  not used
      mgr=Util::WikiDataManager.new
      mgr.run_sparql(sparql_cmd)
    end

    def sparql_cmd
      #  not used
      "SELECT DISTINCT ?item ?pmid ?pmcid ?doi ?itemLabel
       WHERE {
           ?item wdt:P31 wd:Q191067.
           ?item wdt:P698 ?pmid .
         OPTIONAL { ?item wdt:P932 ?pmcid }
         OPTIONAL { ?item wdt:P356 ?doi }
       SERVICE wikibase:label { bd:serviceParam wikibase:language \"en,[AUTO_LANGUAGE]\" . }
       }"
    end

  end

end
