module Util
  class Updater

    attr_accessor :mgr, :study, :subject, :new_line, :tab, :space_char, :double_quote_char, :forward_slash_char

    def initialize(delimiters=nil)
      delimiters = {:new_line=>'||', :tab=>'|', :space_char=>'%20', :double_quote_char=>'%22', :forward_slash_char=>'%2F'} if delimiters.blank?
      #delimiters = {:new_line=>'
#', :tab=>'	', :space_char=>' ', :double_quote_char=>'"', :forward_slash_char=>'/'} if delimiters.blank?
      @new_line = delimiters[:new_line]
      @tab = delimiters[:tab]
      @space_char = delimiters[:space_char]
      @double_quote_char = delimiters[:double_quote_char]
      @forward_slash_char = delimiters[:forward_slash_char]
      @mgr = Util::WikiDataManager.new
    end

    def run(delimiters=nil)
      @subject = 'LAST'
      File.open("public/data.tmp", "w+") do |f|
        loaded_ids= mgr.all_nct_ids_in_wikidata
        # wikidata seems to restrict # of times one session can query to about 1,012.  It aborts there.
        (Study.all.pluck(:nct_id) - loaded_ids)[0..69999].each do |id|
        #self.zika_studies2.each do |id|
        #self.studies_20190211.each do |id|
          if !mgr.study_already_loaded?(id)
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
          end
        end
        f.close
        puts " ====================================="
        File.open("public/data.tmp", "r") do |out|
          File.open("public/data.out", "w+") do |f|
             out.each_line do |line|
               converted_line = line.gsub(' ',space_char).gsub('"',double_quote_char).gsub('/',forward_slash_char)
               puts converted_line
               f << converted_line
             end
          end
        end
      end
    end

    def lines_for(prop_code)
      case prop_code
      when 'Len'
        return "#{line_prefix(prop_code)}\"#{study.brief_title}\""   # Label
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
      # right now, the min/max age properties only have a 'year' unit, so only export those defined as year
      min = study.minimum_age.split(' ')
      max = study.maximum_age.split(' ')
      f << "#{new_line}#{subject}#{tab}P2899#{tab}#{min[0]}U577" if min[1] && min[1].downcase == 'years'
      f << "#{new_line}#{subject}#{tab}P4135#{tab}#{max[0]}U577" if max[1] && max[1].downcase == 'years'
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
      study.study_references.each{ |ref|
        # Nope - it doesn't take a string -needs to be a QCode
        #f << "#{new_line}#{subject}#{tab}P248#{tab}\"https://www.ncbi.nlm.nih.gov/pubmed/?term=#{ref.pmid}\"" if !ref.pmid.blank?
        #  Going to use P854:  Reference URL
        f << "#{new_line}#{subject}#{tab}P854#{tab}\"https://www.ncbi.nlm.nih.gov/pubmed/?term=#{ref.pmid}\"" if !ref.pmid.blank?
      }
    end

    def assign_sponsor_qcodes(f)
      assigned_qcodes=[]
      study.lead_sponsors.each{ |sponsor|
        qcode = Lookup::Sponsor.qcode_for(sponsor.name)
        if !qcode.blank? and !assigned_qcodes.include?(qcode)
          f << "#{new_line}#{subject}#{tab}P859#{tab}#{qcode}" if !qcode.blank?
          assigned_qcodes << qcode
        end
      }
    end

    def assign_collaborators_qcodes(f)
      assigned_qcodes=[]
      study.collaborators.each{ |sponsor|
        qcode = Lookup::Sponsor.qcode_for(sponsor.name)
        if !qcode.blank? and !assigned_qcodes.include?(qcode)
          f << "#{new_line}#{subject}#{tab}P767#{tab}#{qcode}" if !qcode.blank?
          assigned_qcodes << qcode
        end
      }
    end

    def studies_20190211
['NCT00001163', 'NCT00001174', 'NCT00001177', 'NCT00001197', 'NCT00001231', 'NCT00001238', 'NCT00001242', 'NCT00001246', 'NCT00001260', 'NCT00001295', 'NCT00001310', 'NCT00001349', 'NCT00001360', 'NCT00001397', 'NCT00001404', 'NCT00001454', 'NCT00001456', 'NCT00001467', 'NCT00001529', 'NCT00001532', 'NCT00001564', 'NCT00001595', 'NCT00001606', 'NCT00001623', 'NCT00001637', 'NCT00001715', 'NCT00001721', 'NCT00001756', 'NCT00001762', 'NCT00001778', 'NCT00001788', 'NCT00001806', 'NCT00001844', 'NCT00001852', 'NCT00001856', 'NCT00001858', 'NCT00001859', 'NCT00001872', 'NCT00001899', 'NCT00001921', 'NCT00001975', 'NCT00003145', 'NCT00004577', 'NCT00004996', 'NCT00005655', 'NCT00006171', 'NCT00006301', 'NCT00006333', 'NCT00006436', 'NCT00007150', 'NCT00009035', 'NCT00009243', 'NCT00013533', 'NCT00013559', 'NCT00016731', 'NCT00018018', 'NCT00022971', 'NCT00023296', 'NCT00023504', 'NCT00024622', 'NCT00025714', 'NCT00025857']
    end

    def zika_studies2
      ['NCT01048060', 'NCT01037361', 'NCT01031433', 'NCT00995891', 'NCT00967785']
    end

    def zika_studies
      [ 'NCT03611946', 'NCT03158233', 'NCT03229421', 'NCT02996890', 'NCT03106714', 'NCT02979938', 'NCT02952833', 'NCT03624946', 'NCT03679728', 'NCT03008122', 'NCT02963909', 'NCT02937233', 'NCT03425149', 'NCT02856984', 'NCT02810210', 'NCT03263195', 'NCT03393286', 'NCT02733796', 'NCT03330600', 'NCT02840487', 'NCT02916732', 'NCT02996461', 'NCT03443830', 'NCT03255369', 'NCT03776695', 'NCT03014089', 'NCT03188731', 'NCT02831699', 'NCT03161444', 'NCT03204409', 'NCT03343626', 'NCT02794181', 'NCT03776903', 'NCT02943304', 'NCT03110770', 'NCT03227601', 'NCT02874456', 'NCT03037164', 'NCT02887482', 'NCT03055585', 'NCT02741882', 'NCT01099852', 'NCT03206541', 'NCT02809443', 'NCT03078894', 'NCT03553277', 'NCT03534245', 'NCT02957344', 'NCT03631719']
    end

  end
end
