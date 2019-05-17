module Util
  class PubPrepper < Util::Prepper

    attr_reader :client

    def initialize
      super
      @client = Util::Client.new
    end

    def self.data_source
      Pubmed::Publication
    end

    def retrieve_xml_from_pubmed
      pmids=Ctgov::StudyReference.where("reference_type='results_reference'").pluck(:pmid).compact
      pmids.each {|pmid| client.create_pub_xml_record(pmid, client.get_xml_for(pmid)) }
    end

  end
end
