module Lookup
  class Author < SuperLookup
    self.table_name = 'lookup.authors'

    def self.source_data
      # The model that will be used as the source of info
      "Pubmed::Author"
    end

    def label
      :orcid
    end

    def self.all_labels
      Pubmed::Author.uniq.pluck(:orcid).compact
    end

    def self.search_for_qcode(orcid)
      qcode = Util::WikiDataManager.new.get_qcode_for_orcid(orcid)
      return { :qcode => qcode, :name => orcid, :downcase_name => orcid.downcase } if !qcode.blank?
    end

    def self.predefined_qcode
      []
    end
  end
end
