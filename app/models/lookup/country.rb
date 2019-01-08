module Lookup
  class Country < SuperLookup
    self.table_name = 'lookup.countries'

    def self.populate
      self.destroy_all
      data = Roo::Spreadsheet.open("#{Rails.public_path}/countries.xlsx")
      header = data.first
      begin
        (2..data.last_row).each { |i|
          row = Hash[[header, data.row(i)].transpose]
          if !row['qid'].nil? and !row['itemLabel'].nil?
            new(:qcode         => row['qid'],
                :name          => row['itemLabel'],
                :downcase_name => row['itemLabel'].try(:downcase),
                :iso2          => row['iso2'],
                :osm_relid     => row['osm_relid'],
               ).save!
          end
        }
      rescue => error
        puts "#{Time.zone.now}: Unable to populate countries_lookup.  #{error.message}"
      end
    end

    def self.retrieve_data
      system('rm public/countries.csv')
      system(curl_cmd)
    end

    def self.curl_cmd
      # not yet working
      "curl -o public/countries.csv -G 'https://query.wikidata.org/sparql' \
         --header 'Accept: text/csv' \
         --data-urlencode query='
           SELECT DISTINCT ?iso2 ?qid ?osm_relid ?itemLabel
           WHERE {
           ?item wdt:P297 _:b0.
           BIND(strafter(STR(?item), 'http://www.wikidata.org/entity/') as ?qid).
           OPTIONAL { ?item wdt:P1448 ?name .}
           OPTIONAL { ?item wdt:P297  ?iso2 .}
           OPTIONAL { ?item wdt:P402  ?osm_relid .}
           SERVICE wikibase:label { bd:serviceParam wikibase:language 'en,[AUTO_LANGUAGE]' . }
           }
           ORDER BY ?itemLabel"
    end

  end
end
