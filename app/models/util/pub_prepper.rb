module Util
  class PubPrepper < Util::Prepper

    def self.source_model_name
      Pubmed::Publication
    end

    def source_model_name
      Pubmed::Publication
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

    def get_id_maps
      # because there are millions of scholarly articles in wikidata, we will only get the ones specifically referenced by
      # studies in ClinicalTrials.gov.  Lookup::Publication has iterated over all pmids specified in StudyReference
      # and defined the qcodes for those that are already in wikidata. Rows in Lookup::Publication without a qcode
      # represent publications that are referenced in ct.gov but aren't yet in wikidata
      results = []
      Lookup::Publication.where('qcode is not null').pluck(:pmid, :qcode).each {|a|
        results << {a.first => a.last}
      }
      return results.flatten.uniq
    end

  end
end
