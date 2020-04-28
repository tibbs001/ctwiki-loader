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
      QsCreator::Study.new
    end

    def get_id_maps
      lookup_mgr.studies
    end

    def refresh_prop(code)
      # method to create a file of single snaks for just one property
      qsc=QsCreator::Study.new
      qsc.set_delimiters
      File.open("public/refresh_#{code}.txt", "w+") { |f|
        mgr.ids_for_studies_with_prop(code).each { |hash|
          vals = hash.values.first
          f << qsc.quickstatement_to_remove(code, vals)
          qsc.subject = vals.first
          f << qsc.quickstatement_for(code)
        }
      }
    end

    def assign_existing_studies_missing_prop(code)
      # method to create a file of single snaks for just one property
      qsc=QsCreator::Study.new
      qsc.set_delimiters
      File.open("public/assign_#{code}.txt", "w+") { |f|
        mgr.ids_for_studies_without_prop(code).each { |hash|
          nct_id = hash.keys.first
          qsc.subject = hash.values.first
          f << qsc.quickstatement_for(code)
        }
      }
    end

  end
end
