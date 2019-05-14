module Lookup
  class Country < SuperLookup
    self.table_name = 'lookup.countries'

    def self.populate
      self.destroy_all
      new.populate
    end

    def populate
      add_row_for_us
      wikidata_entities.each{|entity|
        begin
          qcode= entity.item.value.chomp.split('/').last
          name=entity[:itemLabel].value
          Lookup::Country.new(
            :qcode         => qcode,
            :name          => name,
            :downcase_name => name.try(:downcase),
            :iso2          => entity[:iso2],
            :osm_relid     => entity[:osm_relid],
          ).save!
        rescue => error
          puts "#{Time.zone.now}: Unable to populate countries_lookup.  #{error.message}"
        end
      }
    end

    def add_row_for_us
      Lookup::Country.new( :qcode=>'Q30',:name=>'United States',:downcase_name=>'united states',:iso2=>'US',:osm_relid=>'148838').save!
    end

    def wikidata_entities
      mgr=Util::WikiDataManager.new
      countries=mgr.run_sparql(sparql_cmd)
    end

    def sparql_cmd
      " SELECT DISTINCT ?item ?iso2 ?qid ?osm_relid ?itemLabel
           WHERE {
           ?item wdt:P297 _:b0.
           BIND(strafter(STR(?item), \"http://www.wikidata.org/entity/\") as ?qid).
           OPTIONAL { ?item wdt:P1448 ?name .}
           OPTIONAL { ?item wdt:P297  ?iso2 .}
           OPTIONAL { ?item wdt:P402  ?osm_relid .}
           SERVICE wikibase:label { bd:serviceParam wikibase:language \"en,[AUTO_LANGUAGE]\" . }
           }
           ORDER BY ?itemLabel"
    end

  end
end
