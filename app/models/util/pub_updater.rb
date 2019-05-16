module Util
  class PubUpdater

    attr_reader :client

    def initialize
       @client = Util::Client.new
    end

    def retrieve_xml_from_pubmed
      pmids=Ctgov::StudyReference.where("reference_type='results_reference'").pluck(:pmid).compact
      ActiveRecord::Base.connection.execute('TRUNCATE TABLE wikidata.pub_xml_records CASCADE')
      pmids.each {|pmid| client.create_pub_xml_record(pmid, client.get_xml_for(pmid)) }
    end

  end
end
