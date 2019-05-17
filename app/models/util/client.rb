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

    def create_xml_record(args)
      Wikidata::PubXmlRecord.where(pmid: args[:pmid]).first_or_create {|rec|rec.content = args[:xml]}
    end

    def populate_publications
      cntr=Wikidata::PubXmlRecord.not_yet_loaded.count
      start_time=Time.zone.now
      puts "Load #{cntr} publications Start Time.....#{start_time}"

      while cntr > 0
        Wikidata::PubXmlRecord.find_each do |xml_record|
          stime=Time.zone.now
          if xml_record.created_study_at.blank?
            import_xml_file(xml_record.content)
            xml_record.created_study_at=Date.today
            xml_record.save!
            puts "#{cntr} saved #{xml_record.nct_id}:  #{Time.zone.now - stime}"
          end
          cntr=cntr-1
        end
      end
      puts "Total Load Time:.....#{Time.zone.now - start_time}"
    end

    def import_xml_file(xml, benchmark: false)
      pub = Nokogiri::XML(xml)
      id = extract_id_from(xml)
      unless Study.find_by(pmid: id).present?
        Wikidata::Publication.new({xml: pub, pmid: id}).create
      end
    end

    private

    def extract_id_from(xml)
      Nokogiri::XML(xml).xpath('//pmid').text
    end

  end
end
