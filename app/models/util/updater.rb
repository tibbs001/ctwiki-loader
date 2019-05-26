module Util
  attr_accessor :xml, :lookup_mgr

  class Updater

    def run
      @lookup_mgr = Util::LookupManager.new
      not_yet_in_wikidata = Lookup::Publication.where('qcode is null').pluck(:pmid)
      to_load = (not_yet_in_wikidata - Pubmed::Publication.all.pluck(:pmid))
      to_load.each {|pmid|
        xml=Util::Client.new.get_xml_for(pmid)
        Pubmed::Publication.new({xml: xml, pmid: pmid, :lookup_mgr=>lookup_mgr}).create
      }
    end

  end
end
