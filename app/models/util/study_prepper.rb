module Util
  class StudyPrepper < Util::Prepper

    def self.source_model_name
      # to do  figure this out later - needed by both class and instance methods - eliminate the duplication
      Ctgov::Study
    end

    def source_model_name
      Ctgov::Study
    end

    def get_id_maps
      results=[]
      cmd="SELECT ?item ?nct_id WHERE { ?item p:P31/ps:P31/wdt:P279* wd:Q30612.  ?item wdt:P3098 ?nct_id . }"
      mgr.run_sparql(cmd).each {|i|
        label = val = ''
        i.each_binding { |name, item|
          label = item.value if name == :nct_id
          val   = item.value.chomp.split('/').last if name == :item
        }
        results << {label.to_s => val }
      }
      return results.flatten.uniq
    end

    def assign_existing_studies_missing_prop(code)
      File.open("public/assign_#{code}.txt", "w+") do |f|
        mgr.ids_for_studies_without_prop(code).each {|hash|
          study = source_model_name.get_for(hash.keys.first)
          @subject = hash.values.first
          f << study.lines_for(code) if study
        }
      end
    end

  end
end
