module Wikidata
  class PubXmlRecord < ActiveRecord::Base
    self.table_name = 'wikidata.pub_xml_records'

    def self.not_yet_loaded(filter=nil)
      if filter
        where('created_pub_at is null and pmid like ?',"%#{filter}")
      else
        where('created_pub_at is null')
      end
    end

  end
end
