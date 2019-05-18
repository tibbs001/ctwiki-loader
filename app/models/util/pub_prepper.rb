module Util
  class PubPrepper < Util::Prepper

    attr_reader :client

    def initialize
      super
      @client = Util::Client.new
      @wikidata_ids=@mgr.wikidata_pub_ids
    end

    def self.source_model_name
      Pubmed::Publication
    end

    def source_model_name
      Pubmed::Publication
    end

    def run(delimiters=nil)
      super
      loaded_ids = @mgr.nctids_in(@wikidata_ids)
      f=File.open("public/#{start_num}_data.tmp", "w+")
      cntr = 1
      # wikidata seems to restrict # of times one session can query to about 1,012.  It aborts there.
      end_num = @start_num + @batch_size
      batch_of_ids = (Ctgov::Study.all.pluck(:nct_id) - loaded_ids)[@start_num..end_num]
      batch_of_ids.each do |id|
        cntr = cntr+1
        begin
          if !loaded_ids.include? id
            @study=Ctgov::Study.where('nct_id=?', id).first

            f << 'CREATE'
            f << lines_for('Len')    # Label
            f << lines_for('Den')    # Description
            f << lines_for('P31')    # instance of a clinical trial
            f << lines_for('P3098')  # nct id
            f << lines_for('P1476')  # title
            f << lines_for('P1813')  # acronym
            f << lines_for('P580')   # start date
            f << lines_for('P582')   # primary completion date
            f << lines_for('P1132')  # enrollment
            f << phase_qcode_lines
            assign_min_max_age(f)
            assign_condition_qcodes(f)
            assign_keyword_qcodes(f)
            assign_country_qcodes(f)
            #assign_facility_qcodes(f)
            assign_intervention_qcodes(f)
            assign_pubmed_ids(f)
            assign_sponsor_qcodes(f)
            f << " #{new_line}#{new_line}"
            loaded_ids << id
          end
        rescue => e
          puts e
          f.close
        end
      end
      f.close
    end

    def retrieve_xml_from_pubmed
      pmids=Ctgov::StudyReference.where("reference_type='results_reference'").pluck(:pmid).compact
      pmids.each {|pmid| client.create_pub_xml_record(pmid, client.get_xml_for(pmid)) }
    end

  end
end
