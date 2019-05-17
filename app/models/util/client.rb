module Util
  class Client
    BASE_URL = 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&retmode=xml'

    def get_xml_for(pmid)
      tries ||= 5
      begin
        #url="#{BASE_URL}&id=#{pmid}&retmode=xml&rettype=abstract"
        #https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&retmode=xml&id=16002928
        url="#{BASE_URL}&id=#{pmid}"
        puts url
        xml=Nokogiri::XML(Faraday.get(url).body)
        sleep(10.seconds)
        return xml
      rescue => e
        #  have been encountering timeout errors.  If encountered, try again
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
