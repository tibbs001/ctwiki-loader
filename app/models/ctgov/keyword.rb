module Ctgov
  class Keyword < StudyRelationship
    self.table_name = 'ctgov.keywords'

    def self.top_level_label
      '//keyword'
    end

    def self.create_all_from(opts)
      objects = super
      import(objects)
    end

    def attribs
      {:name => opts[:xml].text}
    end

  end
end
