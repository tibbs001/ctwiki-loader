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

    def pubmed_quickstatements
      return_str = ''
      File.open("public/add_publication_links.tmp", "w+") do |f|
        wikidata_nct_ids= @wikidata_study_ids.keys
        study_refs=Ctgov::StudyReference.where("reference_type='results_reference'")
        study_refs.each{|sr|
          if wikidata_nct_ids.include? sr.nct_id
            pub_qcode = Lookup::Publication.qcode_for(sr.pmid)
            if !pub_qcode.blank?
              study_qcode=@wikidata_study_ids[sr.nct_id]
              # Link pub to study
              return_str << "#{new_line}#{pub_qcode}#{tab}P921#{tab}#{study_qcode}"
              # Link study to pub
              return_str << "#{new_line}#{study_qcode}#{tab}P248#{tab}#{pub_qcode}"
              # provide reference to NCBI URL
              return_str << "#{new_line}#{subject}#{tab}P854#{tab}\"https://www.ncbi.nlm.nih.gov/pubmed/?term=#{sr.url}\"" if !sr.url.blank?
            end
          end
        }
      end
      return return_str
    end

    def retrieve_xml_from_pubmed
      pmids=Ctgov::StudyReference.where("reference_type='results_reference'").pluck(:pmid).compact
      pmids.each {|pmid| client.create_pub_xml_record(pmid, client.get_xml_for(pmid)) }
    end

  end
end
