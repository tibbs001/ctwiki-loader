module Util
  class Client
    BASE_URL = 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&retmode=xml'

    def get_local_xml_for(pmid)
      tries ||= 5
      begin
        xml_file_name="/aact-files/xml_downloads/pubmed_xml/#{pmid[0]}/#{pmid}.xml"
        file = File.open(xml_file_name)
        return Nokogiri::XML(file)
      rescue => e
        #  have been encountering timeout errors.  If encountered, try again
        if (tries -=1) > 0
          puts "Error getting: #{xml_file_name}"
          puts e.inspect
          retry
        end
        puts "Giving up on #{pmid}. Move on to next publication"
      end
    end

    def get_xml_for(pmid)
      tries ||= 5
      begin
        #url="#{BASE_URL}&id=#{pmid}&retmode=xml&rettype=abstract"
        #https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&retmode=xml&id=29895572
        url="#{BASE_URL}&id=#{pmid}"
        puts url
        # For some reason, this command now makes the entrez API think we're committing abuse and returns:
        #https://misuse.ncbi.nlm.nih.gov/error/abuse.shtml?db=pubmed&amp;id=29895572&amp;retmode=xml
        # So just pull the xml down and save locally for now.  Have emailed ncbi support
        #xml=Nokogiri::XML(Faraday.get(url).body)
        system("curl -k '#{url}' > #{xml_file_name}")
        file = File.open(xml_file_name)
        sleep(2.seconds)
        return Nokogiri::XML(file)
      rescue => e
        #  have been encountering timeout errors.  If encountered, try again
        sleep(2.seconds)
        if (tries -=1) > 0
          puts "Error calling: #{url}"
          puts e.inspect
          retry
        end
        puts "Giving up on #{pmid}. Move on to next publication"
      end
    end

  end
end
