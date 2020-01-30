module Lookup
  class Condition < SuperLookup
    self.table_name = 'lookup.conditions'

    def self.label
      :mesh_term
    end

    def self.populate
      #self.destroy_all  # too slow!  does this one row at a time.
      Lookup::Condition.connection.execute('truncate table lookup.conditions;')
      new.populate
    end

    def wikidata_entities
      mgr=Util::WikiDataManager.new
      countries=mgr.run_sparql(sparql_cmd)
    end

    def sparql_cmd
      # Item's type is: health problem or sub-type or sub-sub-type/etc
      # health problems:  ?item p:P31/ps:P31/wdt:P279* wd:Q2057971 .
      # physiological problems:  ?item p:P31/ps:P31/wdt:P279* wd:Q7189713 .
      # MeSH Code:  P672
      # disease:  ?item p:P31/ps:P31/wdt:P279* wd:Q12136 .
      #
      "SELECT ?item ?itemLabel ?instanceOf ?instanceOfLabel WHERE {
         ?item p:P31/ps:P31/wdt:P279* wd:Q2057971 .
         OPTIONAL {?item wdt:P31 ?instanceOf }
         SERVICE wikibase:label { bd:serviceParam wikibase:language \"[AUTO_LANGUAGE],en\". }
       } "
    end

    def populate
      wikidata_entities.each{|entity|
        begin
          qcode= entity.item.value.chomp.split('/').last
          entity.each_binding { |name, item|
            puts "#{name}   #{item}"
          } if !entity.blank?
          name=entity[:itemLabel].value
          if entity[:instanceOfLabel]
            instance_qcode = entity[:instanceOf].value.chomp.split('/').last
            type = "#{instance_qcode}: #{entity[:instanceOfLabel]}"
          end
          Lookup::Condition.new(
            :qcode             => qcode,
            :name              => name,
            :downcase_name     => name.try(:downcase),
            :wiki_description  => type,
          ).save!
        rescue => error
          puts "#{Time.zone.now}: Unable to populate Lookup::Condition.  #{error.message}"
        end
      }
    end

  end
end
