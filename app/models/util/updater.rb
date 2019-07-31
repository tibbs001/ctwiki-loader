module Util

  class Updater

    def load_local_pubs
      lookup_mgr = Util::LookupManager.new
      Ctgov::StudyReference.all.pluck(:pmid).uniq.each {|pmid|
        xml=Util::Client.new.get_local_xml_for(pmid)
        Pubmed::Publication.new({xml: xml, pmid: pmid, :lookup_mgr=>lookup_mgr}).create
      }
    end

    def load_pub_files
      lookup_mgr = Util::LookupManager.new
      cntr = 1
      while cntr < 10 {
        dir_name="/aact-files/xml_downloads/pubmed_xml/#{cntr}/"
        file_names=Dir.entries(dir_name) - ['.','..']
        file_names.each { |file_name|
          pmid = file_name.split('.').first
          xml_file_name="/aact-files/xml_downloads/pubmed_xml/#{cntr}/#{pmid}.xml"
          file = File.open(xml_file_name)
          xml= Nokogiri::XML(file)
          Pubmed::Publication.new({xml: xml, pmid: pmid, :lookup_mgr=>lookup_mgr}).create
        }
        cntr = cntr + 1
      }
    end

    def load_pubs
      lookup_mgr = Util::LookupManager.new
      not_yet_in_wikidata = Lookup::Publication.where('qcode is null').pluck(:pmid)
      to_load = (not_yet_in_wikidata - Pubmed::Publication.all.pluck(:pmid))
      to_load.each {|pmid|
        xml=Util::Client.new.get_xml_for(pmid)
        Pubmed::Publication.new({xml: xml, pmid: pmid, :lookup_mgr=>lookup_mgr}).create
      }
    end

  end
end
