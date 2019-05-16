module Lookup
  class Publication < SuperLookup
    self.table_name = 'lookup.publications'
    @@qcode_map = where('qcode is not null').pluck(:qcode,:pmid)

    def self.qcode_for(pmid)
      code = @@qcode_map.select{|entry| entry if entry[1] == pmid }
      code.first[0] if code.size > 0
    end

    def self.populate
      # We will need to run this in many iterations because the sparql query endpoint seems to have a limit
      # After getting the qcode for about 100 publications, it will lock us out.  So we'll need to restart
      new.populate
    end

    def self.xxxxxxxqcode_for(pmid)
      return if pmid.nil?
      results = Lookup::Publication.where('qcode is not null and pmid = ?',pmid)
      return results.first.qcode if results.size > 0
    end

    def populate
      mgr = Util::WikiDataManager.new
      existing_qcodes = Lookup::Publication.where('qcode is not null')
      study_ref_ids_yet_to_load.each {|val|
        ref = StudyReference.find(val['id'])
        qcode = mgr.get_qcode_for_pmid(ref.pmid)
        unless existing_qcodes.include? qcode
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
          existing_qcodes << qcode if !qcode.nil?
        end
      }
    end

    def study_ref_ids_yet_to_load
      cmd="select id from ctgov.study_references where pmid is not null and pmid not in (select pmid from lookup.publications)"
      ActiveRecord::Base.connection.execute(cmd)
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
