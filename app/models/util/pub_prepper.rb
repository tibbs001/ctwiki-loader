module Util
  class PubPrepper < Util::Prepper

    def self.source_model_name
      Pubmed::Publication
    end

    def source_model_name
      Pubmed::Publication
    end

    def get_id_maps
      lookup_mgr.publications
    end

  end
end
