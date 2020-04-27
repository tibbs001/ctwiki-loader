module Util
  class StudyPrepper < Util::Prepper

    def self.source_model_name
      # to do  figure this out later - needed by both class and instance methods - eliminate the duplication
      Ctgov::Study
    end

    def source_model_name
      Ctgov::Study
    end

    def qs_creator
      QsCreator::Study
    end

    def assign_existing_studies_missing_prop(code)
      # method to create a file of single snaks for just one property
      File.open("public/assign_#{code}.txt", "w+") do |f|
        mgr.ids_for_studies_without_prop(code).each {|hash|
          nct_id = hash.keys.first
          study = source_model_name.get_for(nct_id, lookup_mgr)
          if study
            study.subject = hash.values.first
            f << study.quickstatement_for(code)
          end
        }
      end
    end

    def get_id_maps
      lookup_mgr.studies
    end
  end
end
