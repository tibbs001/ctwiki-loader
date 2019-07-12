module Util
  class NciClient
    BASE_URL = 'https://clinicaltrialsapi.cancer.gov/v1/clinical-trials?'

    attr_reader :url, :processed_studies, :errors
    def initialize(nct_id: nil)
      @url = "#{BASE_URL}size=50&"
    end

    def download_files
      tries ||= 5
      batch_counter=1
      while batch_counter < 12000
        puts "Getting next 50 NCI studies starting at #{batch_counter}"
        file_name="/aact-files/json_downloads/#{Time.zone.now.strftime("%Y%m%d-%H")}_nci_#{batch_counter}.json"
        file = File.new file_name, 'w'
        begin
          next_url="#{@url}from=#{batch_counter}"
          puts next_url
          download = RestClient::Request.execute({
            url:          next_url,
            method:       :get,
            content_type: 'application/json'
          })
        rescue Errno::ECONNRESET => e
          if (tries -=1) > 0
            puts "  download failed. trying again..."
            retry
          end
        end
        file.binmode
        file.write(download)
        file.size
        batch_counter = batch_counter + 50
      end
    end

    def get_data_for(nct_id)
      tries ||= 5
      begin
        url="#{BASE_URL}nct_id=#{nct_id}"
        puts url
        return JSON.parse(Faraday.get(url).body)['trials'].first
      rescue => e
        #  have been encountering timeout errors.  If encountered, try again
        if (tries -=1) > 0
          puts "Error calling: #{url}"
          puts e.inspect
          retry
        end
        puts "Giving up on #{nct_id}.  Move on to next study"
      end
    end

  end
end
