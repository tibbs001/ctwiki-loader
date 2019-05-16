module Util
  class Updater

    attr_accessor :mgr, :study, :start_num, :subject, :new_line, :tab, :space_char, :double_quote_char, :forward_slash_char, :batch_size, :wikidata_study_ids

    def initialize(args={})
      @batch_size = 1000
      @start_num = args[:start_num]
      delimiters = args[:delimiters]
      delimiters = {:new_line=>'||', :tab=>'|', :space_char=>'%20', :double_quote_char=>'%22', :forward_slash_char=>'%2F'} if delimiters.blank?
      #delimiters = {:new_line=>'
#', :tab=>'	', :space_char=>' ', :double_quote_char=>'"', :forward_slash_char=>'/'} if delimiters.blank?
      @new_line = delimiters[:new_line]
      @tab = delimiters[:tab]
      @space_char = delimiters[:space_char]
      @double_quote_char = delimiters[:double_quote_char]
      @forward_slash_char = delimiters[:forward_slash_char]
      @mgr = Util::WikiDataManager2.new
      @wikidata_study_ids=@mgr.wikidata_study_ids
    end

    def add_publication_links
      File.open("public/add_publication_links.tmp", "w+") do |f|
        @wikidata_study_ids.each do |ids|
          nct_id = ids.keys.first
          @subject = ids.values.first
          puts @subject
          #@study=Study.where('nct_id=?', nct_id).first
          #assign_pubmed_ids(f) if !@study.nil?
        end
      end
    end

    def add_min_max_age
      File.open("public/data.tmp", "w+") do |f|
        @wikidata_study_ids.each do |id|
          if mgr.study_already_loaded?(id)
            @study=Study.where('nct_id=?', id).first
            @subject=mgr.qcodes_for_nct_id(id).first
            assign_min_max_age(f)
          end
        end
      end
    end

    def self.run(start_num)
      batch_size = 1000
      cntr = start_num.to_i
      until cntr > Study.count do
        self.new({:start_num => cntr}).run
        cntr = cntr + batch_size
        sleep(10.minutes)
      end
    end

    def add_min_max_age
      File.open("public/data.tmp", "w+") do |f|
        loaded_ids= mgr.all_nct_ids_in_wikidata
        loaded_ids.each do |id|
          if mgr.study_already_loaded?(id)
            @study=Study.where('nct_id=?', id).first
            @subject=mgr.qcodes_for_nct_id(id).first
            puts "==============================="
            puts "NCT ID:  #{id}  QCode: #{subject}"
            puts "==============================="
            assign_min_max_age(f)
          end
        end
      end
    end

    def run(delimiters=nil)
      @subject = 'LAST'
      loaded_ids = @mgr.nctids_in(@wikidata_study_ids)
      f=File.open("public/#{start_num}_data.tmp", "w+")
      cntr = 1
      # wikidata seems to restrict # of times one session can query to about 1,012.  It aborts there.
      end_num = @start_num + @batch_size
      batch_of_ids = (Study.all.pluck(:nct_id) - loaded_ids)[@start_num..end_num]
      batch_of_ids.each do |id|
        cntr = cntr+1
        begin
          if !loaded_ids.include? id
            @study=Study.where('nct_id=?', id).first

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

    def lines_for(prop_code)
      case prop_code
      when 'Len'
        return "#{line_prefix(prop_code)}\"#{study.brief_title[0..244]}\""   # Label
      when 'Den'
        return "#{line_prefix(prop_code)}\"clinical trial\""     # Description
      when 'P31'
        return "#{line_prefix(prop_code)}Q30612"   # instance of a clinical trial
      when 'P3098'  # NCT ID
        return "#{line_prefix(prop_code)}\"#{study.nct_id}\""
      when 'P1476'  # title
        return "#{line_prefix(prop_code)}en:\"#{study.official_title}\"" if study.official_title
      when 'P1813'  # acronym
        return "#{line_prefix(prop_code)}en:\"#{study.acronym}\"" if study.acronym
      when 'P1132'  # number of participants
        return "#{line_prefix(prop_code)}#{study.enrollment}" if study.enrollment
      when 'P6099'  # study phase
        return phase_qcode_lines
      when 'P580'   # start date
        return "#{line_prefix(prop_code)}+#{quickstatement_date(study.start_date, study.start_month_year)}" if study.start_date
      when 'P582'   # primary completion date
        return "#{line_prefix(prop_code)}+#{quickstatement_date(study.primary_completion_date, study.primary_completion_month_year)}" if study.primary_completion_date
      end
    end

    def line_prefix(prop_code)
      return "#{new_line}#{subject}#{tab}#{prop_code}#{tab}"
    end

    def quickstatement_date(dt, dt_str)
      # TODO Refine date so it has month precision when the day isn't provided
      # TODO Add qualifiers for Anticipated vs Actual
      #Time values must be in format  +1967-01-17T00:00:00Z/11.  (/11 means day precision)
      if dt_str.count(' ') == 1  # if only one space in the date string, it must not have a day, so set to month precision.
        "#{dt}T00:00:00Z/10"
      else
        "#{dt}T00:00:00Z/11"
      end
    end

    def assign_existing_studies_missing_prop(code)
      File.open("public/assign_#{code}.txt", "w+") do |f|
        mgr.ids_for_studies_without_prop(code).each {|hash|
          @study = Study.where('nct_id=?', hash.keys.first).first
          @subject = hash.values.first
          f << lines_for(code) if study
        }
      end
    end

    def assign_min_max_age(f)
      # year/month unit is identified by appending 'U' to the integer of the year or month Q-value, and
      # tacking it onto the end of the actual value
      min = study.minimum_age.split(' ')
      max = study.maximum_age.split(' ')

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
      f << "#{new_line}#{subject}#{tab}?????#{tab}en:\"#{study.design.intervention_for_wiki}\""
    end

    def phase_qcode_lines
      return nil if study.phase.blank?
      return_str=''
      return_str << "#{new_line}#{subject}#{tab}P6099#{tab}Q42824069" if study.phase.include? '1'
      return_str << "#{new_line}#{subject}#{tab}P6099#{tab}Q42824440" if study.phase.include? '2'
      return_str << "#{new_line}#{subject}#{tab}P6099#{tab}Q42824827" if study.phase.include? '3'
      return_str << "#{new_line}#{subject}#{tab}P6099#{tab}Q42825046" if study.phase.include? '4'
      return return_str
    end

    def assign_facility_qcodes(f)
      study.facilities.each{ |facility|
        qcode = Lookup::Organization.qcode_for(facility.name)
        f << "#{new_line}#{subject}#{tab}P6153#{tab}#{qcode}" if !qcode.blank?
      }
    end

    def assign_keyword_qcodes(f)
      study.keywords.each{ |keyword|
        qcode = Lookup::Keyword.qcode_for(keyword.name)
        #topics are: Q200801
        f << "#{new_line}#{subject}#{tab}P921#{tab}#{qcode}" if !qcode.blank?
      }
    end

    def assign_condition_qcodes(f)
      assigned_qcodes=[]
      conditions = study.browse_conditions.pluck(:downcase_mesh_term).uniq
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
      study.active_countries.each{ |country|
        qcode = Lookup::Country.qcode_for(country.name)
        if !qcode.blank? and !assigned_qcodes.include?(qcode)
          f << "#{new_line}#{subject}#{tab}P17#{tab}#{qcode}" if !qcode.blank?
          assigned_qcodes << qcode
        end
      }
    end

    def assign_intervention_qcodes(f)
      assigned_qcodes=[]
      interventions = study.browse_interventions.pluck(:downcase_mesh_term).uniq
      interventions.each{ |intervention|
        qcode = Lookup::Intervention.qcode_for(intervention)
        if !qcode.blank? and !assigned_qcodes.include?(qcode)
          f << "#{new_line}#{subject}#{tab}P4844#{tab}#{qcode}" if !qcode.blank?
          assigned_qcodes << qcode
        end
      }
    end

    def assign_urls(f)
      study.documents.each{ |ref|
        f << "#{new_line}#{subject}#{tab}P854#{tab}\"https://www.ncbi.nlm.nih.gov/pubmed/?term=#{ref.url}\"" if !ref.url.blank?
      }
    end

    def assign_pubmed_ids(f)
      @study.study_references.each{ |ref|
        #if ref.reference_type=='results_reference'
          pub_qcode = Lookup::Publication.qcode_for(ref.pmid)
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
      study.lead_sponsors.each{ |sponsor|
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
