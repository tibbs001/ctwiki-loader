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

    def assign_existing_studies_missing_prop(code)
      # method to create a file of single snaks for just one property
      qsc=QsCreator::Study.new
      qsc.set_delimiters
      File.open("public/assign_#{code}.txt", "w+") do |f|
        mgr.ids_for_studies_without_prop(code).each {|hash|
          nct_id = hash.keys.first
          study = qsc.get_for(nct_id)
          if study
            qsc.subject = hash.values.first
            f << qsc.quickstatement_for(code)
          end
        }
      end
    end

    def refresh_prop(code)
      # method to create a file of single snaks for just one property
      # remove the old value and add the new value
      qsc=QsCreator::Study.new
      qsc.set_delimiters
      File.open("public/refresh_#{code}.txt", "w+") { |f|
        # go grab the data for all studies with this property
        # info includes nct_id, qcode, and subj value (currently assuming it's also a qcode)
        mgr.info_for_studies_with_prop(code).each { |hash|
          nct_id = hash.keys.first
          study = qsc.get_for(nct_id)
          if study
            vals = hash.values.first
            qsc.subject = vals.first
            qsc.object = vals.last
            old_stmt = qsc.quickstatement_with_old_subject(code)
            new_stmt = qsc.quickstatement_with_new_subject(code)
            if old_stmt != new_stmt
              f << "\n#{-old_stmt}"  # line that will remove old
              f << "\n#{new_stmt}"   # line that will add new
            end
          end
        }
      }
    end

  end
end
