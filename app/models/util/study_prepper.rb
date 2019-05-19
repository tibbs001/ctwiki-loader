module Util
  class StudyPrepper < Util::Prepper

    def initialize(args={})
      super
      @mgr = Util::WikiDataManager2.new
      @wikidata_ids=@mgr.wikidata_study_ids
    end

    def self.source_model_name
      # to do  figure this out later - needed by both class and instance methods - eliminate the duplication
      Ctgov::Study
    end

    def source_model_name
      Ctgov::Study
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
