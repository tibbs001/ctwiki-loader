module Util
  class StudyPrepper < Util::Prepper

    def initialize(args={})
      super
      @mgr = Util::WikiDataManager2.new
      @wikidata_ids=@mgr.wikidata_study_ids
    end

    def self.data_source
      Ctgov::Study
    end

    def data_source
      # to do  figure this out later - eliminate duplicate class/instance methods
      Ctgov::Study
    end

    def add_publication_links
      File.open("public/add_publication_links.tmp", "w+") do |f|
        wikidata_nct_ids= @wikidata_study_ids.keys
        study_refs=Ctgov::StudyReference.where("reference_type='results_reference'")
        study_refs.each{|sr|
          if wikidata_nct_ids.include? sr.nct_id
            pub_qcode = Lookup::Publication.qcode_for(sr.pmid)
            if !pub_qcode.blank?
              study_qcode=@wikidata_study_ids[sr.nct_id]
              puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> link #{pub_qcode} to #{study_qcode}"
              # Link pub to study
              f << "#{new_line}#{pub_qcode}#{tab}P921#{tab}#{study_qcode}"
              # Link study to pub
              f << "#{new_line}#{study_qcode}#{tab}P248#{tab}#{pub_qcode}"
            end
          end
        }
      end
    end

    def add_min_max_age
      File.open("public/data.tmp", "w+") do |f|
        @wikidata_study_ids.each do |id|
          if mgr.study_already_loaded?(id)
            @source_entity=Ctgov::Study.where('nct_id=?', id).first
            @subject=mgr.qcodes_for_nct_id(id).first
            assign_min_max_age(f)
          end
        end
      end
    end

    def add_min_max_age
      File.open("public/data.tmp", "w+") do |f|
        loaded_ids= mgr.all_nct_ids_in_wikidata
        loaded_ids.each do |id|
          if mgr.study_already_loaded?(id)
            @source_entity=Ctgov::Study.where('nct_id=?', id).first
            @subject=mgr.qcodes_for_nct_id(id).first
            assign_min_max_age(f)
          end
        end
      end
    end

    def run(delimiters=nil)
      super
      loaded_ids = @mgr.nctids_in(@wikidata_ids)
      f=File.open("public/#{start_num}_data.tmp", "w+")
      cntr = 1
      # wikidata seems to restrict # of times one session can query to about 1,012.  It aborts there.
      end_num = @start_num + @batch_size
      batch_of_ids = (data_source.all_ids - loaded_ids)[@start_num..end_num]
      batch_of_ids.each do |id|
        cntr = cntr+1
        #begin
          if !loaded_ids.include? id
            @source_entity=Ctgov::Study.where('nct_id=?', id).first

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
        #rescue => e
        #  puts e
        #  f.close
        #end
      end
      f.close
    end

    def line_prefix(prop_code)
      return "#{new_line}#{subject}#{tab}#{prop_code}#{tab}"
    end

    def assign_existing_studies_missing_prop(code)
      File.open("public/assign_#{code}.txt", "w+") do |f|
        mgr.ids_for_studies_without_prop(code).each {|hash|
          @source_entity = Ctgov::Study.where('nct_id=?', hash.keys.first).first
          @subject = hash.values.first
          f << lines_for(code) if study
        }
      end
    end

    def assign_min_max_age(f)
      # year/month unit is identified by appending 'U' to the integer of the year or month Q-value, and
      # tacking it onto the end of the actual value
      min = @source_entity.minimum_age.split(' ')
      max = @source_entity.maximum_age.split(' ')

      f << "#{new_line}#{subject}#{tab}P2899#{tab}#{min[0]}U577" if min[1] && min[1].downcase == 'years'
      f << "#{new_line}#{subject}#{tab}P4135#{tab}#{max[0]}U577" if max[1] && max[1].downcase == 'years'
      f << "#{new_line}#{subject}#{tab}P2899#{tab}#{min[0]}U5151" if min[1] && min[1].downcase == 'months'
      f << "#{new_line}#{subject}#{tab}P4135#{tab}#{max[0]}U5151" if max[1] && max[1].downcase == 'months'
    end

    def get_qcode_for_url(url)
      # API call to get qcode for url
    end

    def create_research_design(f)
      f << 'CREATE'
      f << "#{new_line}#{subject}#{tab}P31#{tab}Q1438035"   # instance of research design
      f << "#{new_line}#{subject}#{tab}?????#{tab}en:\"#{@source_entity.design.intervention_for_wiki}\""
    end

    def assign_facility_qcodes(f)
      @source_entity.facilities.each{ |facility|
        qcode = Lookup::Organization.qcode_for(facility.name)
        f << "#{new_line}#{subject}#{tab}P6153#{tab}#{qcode}" if !qcode.blank?
      }
    end

    def assign_keyword_qcodes(f)
      @source_entity.keywords.each{ |keyword|
        qcode = Lookup::Keyword.qcode_for(keyword.name)
        #topics are: Q200801
        f << "#{new_line}#{subject}#{tab}P921#{tab}#{qcode}" if !qcode.blank?
      }
    end

    def assign_condition_qcodes(f)
      assigned_qcodes=[]
      conditions = @source_entity.browse_conditions.pluck(:downcase_mesh_term).uniq
      conditions.each{ |condition|
        qcode = Lookup::Condition.qcode_for(condition)
        if !qcode.blank? and !assigned_qcodes.include?(qcode)
          f << "#{new_line}#{subject}#{tab}P1050#{tab}#{qcode}"
          assigned_qcodes << qcode
        end
      }
    end

    def assign_country_qcodes(f)
      assigned_qcodes=[]
      @source_entity.active_countries.each{ |country|
        qcode = Lookup::Country.qcode_for(country.name)
        if !qcode.blank? and !assigned_qcodes.include?(qcode)
          f << "#{new_line}#{subject}#{tab}P17#{tab}#{qcode}" if !qcode.blank?
          assigned_qcodes << qcode
        end
      }
    end

    def assign_intervention_qcodes(f)
      assigned_qcodes=[]
      interventions = @source_entity.browse_interventions.pluck(:downcase_mesh_term).uniq
      interventions.each{ |intervention|
        qcode = Lookup::Intervention.qcode_for(intervention)
        if !qcode.blank? and !assigned_qcodes.include?(qcode)
          f << "#{new_line}#{subject}#{tab}P4844#{tab}#{qcode}" if !qcode.blank?
          assigned_qcodes << qcode
        end
      }
    end

    def assign_urls(f)
      @source_entity.documents.each{ |ref|
        f << "#{new_line}#{subject}#{tab}P854#{tab}\"https://www.ncbi.nlm.nih.gov/pubmed/?term=#{ref.url}\"" if !ref.url.blank?
      }
    end

    def assign_pubmed_ids(f)
      puts "Study has #{@source_entity.references.size} publications"
      @source_entity.study_references.each{ |ref|
        #if ref.reference_type=='results_reference'
          pub_qcode = Lookup::Publication.qcode_for(ref.pmid)
          puts "pub qcode is #{pub_qcode}"
          if !pub_qcode.blank?
            # Link pub to study
            f << "#{new_line}#{pub_qcode}#{tab}P921#{tab}#{subject}"
            # Link study to pub
            f << "#{new_line}#{subject}#{tab}P248#{tab}#{pub_qcode}"
          end
        #end
      }
    end

    def assign_sponsor_qcodes(f)
      already_assigned_to_this_study=[]
      @source_entity.lead_sponsors.each{ |sponsor|
        qcode = Lookup::Sponsor.qcode_for(sponsor.name)
        if !qcode.blank? and !already_assigned_to_this_study.include?(qcode)
          f << "#{new_line}#{subject}#{tab}P859#{tab}#{qcode}" if !qcode.blank?
          already_assigned_to_this_study << qcode
        end
      }
    end

    def assign_collaborators_qcodes(f)
      already_assigned_to_this_study=[]
      study.collaborators.each{ |sponsor|
        qcode = Lookup::Sponsor.qcode_for(sponsor.name)
        if !qcode.blank? and !already_assigned_to_this_study.include?(qcode)
          f << "#{new_line}#{subject}#{tab}P767#{tab}#{qcode}" if !qcode.blank?
          already_assigned_to_this_study << qcode
        end
      }
    end

  end
end
