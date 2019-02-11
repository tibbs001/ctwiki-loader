module Util
  class Exporter

    attr_accessor :study, :new_line, :tab

    def run(delimiters=nil)
      #delimiters = {:new_line=>'||', :tab=>'|'} if delimiters.blank?
      delimiters = {:new_line=>'
', :tab=>'	'} if delimiters.blank?
      @new_line = delimiters[:new_line]
      @tab = delimiters[:tab]
      mgr = Util::WikiDataManager.new
      File.open("public/data.txt", "w+") do |f|
        #Study.all[0..29].each do |id|
        #self.zika_studies.each do |id|
        self.studies_20190211.each do |id|
          if !mgr.study_already_loaded?(id)
            @study=Study.where('nct_id=?', id).first

            f << 'CREATE'
            f << "#{new_line}LAST#{tab}Len#{tab}\"#{study.brief_title}\""   # Label
            f << "#{new_line}LAST#{tab}Den#{tab}\"clinical trial\""     # Description

            if !study.calculated_value.has_single_facility
              f << "#{new_line}LAST#{tab}P31#{tab}Q6934595"   # instance of a multi-center clinical trial
            else
              f << "#{new_line}LAST#{tab}P31#{tab}Q30612"     # instance of a clinical trial
            end
            f << "#{new_line}LAST#{tab}P3098#{tab}\"#{study.nct_id}\""
            #  seems title needs to specify language & is an object
            f << "#{new_line}LAST#{tab}P1476#{tab}en:\"#{study.official_title}\"" if study.official_title
            f << "#{new_line}LAST#{tab}P1813#{tab}en:\"#{study.acronym}\"" if study.acronym
            f << "#{new_line}LAST#{tab}P580#{tab}+#{study.quickstatement_date(study.start_date)}" if study.start_date
            f << "#{new_line}LAST#{tab}P582#{tab}+#{study.quickstatement_date(study.primary_completion_date)}" if study.primary_completion_date
            f << "#{new_line}LAST#{tab}P1132#{tab}#{study.enrollment}"  if study.enrollment
            assign_min_max_age(f)
            assign_phase_qcodes(f)
            assign_condition_qcodes(f)
            assign_country_qcodes(f)
            assign_facility_qcodes(f)
            assign_intervention_qcodes(f)
            assign_pubmed_ids(f)
            assign_sponsor_qcodes(f)
            f << " #{new_line}#{new_line}"
          end
        end
      end

    end

    def assign_min_max_age(f)
      # right now, the min/max age properties only have a 'year' unit, so only export those defined as year
      min = study.minimum_age.split(' ')
      max = study.maximum_age.split(' ')
      f << "#{new_line}LAST#{tab}P2899#{tab}#{min[0]}" if min[1] && min[1].downcase == 'years'
      f << "#{new_line}LAST#{tab}P4135#{tab}#{max[0]}" if max[1] && max[1].downcase == 'years'
    end

    def get_qcode_for_url(url)
      # API call to get qcode for url
    end

    def quickstatement_date(dt)
      #Time values must be in format  +1967-01-17T00:00:00Z/11.  (/11 means day precision)
      "#{dt}T00:00:00Z/11"
    end

    def create_research_design(f)
      f << 'CREATE'
      f << "#{new_line}LAST#{tab}P31#{tab}Q1438035"   # instance of research design
      f << "#{new_line}LAST#{tab}?????#{tab}en:\"#{study.design.intervention_for_wiki}\""
    end

    def assign_phase_qcodes(f)
      return nil if study.phase.blank?
      f << "#{new_line}LAST#{tab}P6099#{tab}Q42824069" if study.phase.include? '1'
      f << "#{new_line}LAST#{tab}P6099#{tab}Q42824440" if study.phase.include? '2'
      f << "#{new_line}LAST#{tab}P6099#{tab}Q42824827" if study.phase.include? '3'
      f << "#{new_line}LAST#{tab}P6099#{tab}Q42825046" if study.phase.include? '4'
    end

    def assign_facility_qcodes(f)
      study.facilities.each{ |facility|
        qcode = Lookup::Organization.qcode_for(facility.name)
        f << "#{new_line}LAST#{tab}P6153#{tab}#{qcode}" if !qcode.blank?
      }
    end

    def assign_keyword_qcodes(f)
      keywords.each{ |keyword|
        qcode = Lookup::Keyword.qcode_for(keyword.name)
        #topics are: Q200801
        f << "#{new_line}LAST#{tab}P921#{tab}#{qcode}" if !qcode.blank?
      }
    end

    def assign_condition_qcodes(f)
      assigned_qcodes=[]
      conditions = study.browse_conditions.pluck(:downcase_mesh_term).uniq
      conditions.each{ |condition|
        qcode = Lookup::Condition.qcode_for(condition)
        if !qcode.blank? and !assigned_qcodes.include?(qcode)
          f << "#{new_line}LAST#{tab}P1050#{tab}#{qcode}"
          assigned_qcodes << qcode
        end
      }
    end

    def assign_country_qcodes(f)
      assigned_qcodes=[]
      study.active_countries.each{ |country|
        qcode = Lookup::Country.qcode_for(country.name)
        if !qcode.blank? and !assigned_qcodes.include?(qcode)
          f << "#{new_line}LAST#{tab}P17#{tab}#{qcode}" if !qcode.blank?
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
          f << "#{new_line}LAST#{tab}P4844#{tab}#{qcode}" if !qcode.blank?
          assigned_qcodes << qcode
        end
      }
    end

    def assign_pubmed_ids(f)
      study.study_references.each{ |ref|
        f << "#{new_line}LAST#{tab}P698#{tab}\"#{ref.pmid}\"" if !ref.pmid.blank?
      }
    end

    def assign_sponsor_qcodes(f)
      assigned_qcodes=[]
      study.lead_sponsors.each{ |sponsor|
        qcode = Lookup::Sponsor.qcode_for(sponsor.name)
        if !qcode.blank? and !assigned_qcodes.include?(qcode)
          f << "#{new_line}LAST#{tab}P859#{tab}#{qcode}" if !qcode.blank?
          assigned_qcodes << qcode
        end
      }
    end

    def assign_collaborators_qcodes(f)
      assigned_qcodes=[]
      study.collaborators.each{ |sponsor|
        qcode = Lookup::Sponsor.qcode_for(sponsor.name)
        if !qcode.blank? and !assigned_qcodes.include?(qcode)
          f << "#{new_line}LAST#{tab}P767#{tab}#{qcode}" if !qcode.blank?
          assigned_qcodes << qcode
        end
      }
    end

    def studies_20190211
['NCT00001163', 'NCT00001174', 'NCT00001177', 'NCT00001197', 'NCT00001231', 'NCT00001238', 'NCT00001242', 'NCT00001246', 'NCT00001260', 'NCT00001295', 'NCT00001310', 'NCT00001349', 'NCT00001360', 'NCT00001397', 'NCT00001404', 'NCT00001454', 'NCT00001456', 'NCT00001467', 'NCT00001529', 'NCT00001532', 'NCT00001564', 'NCT00001595', 'NCT00001606', 'NCT00001623', 'NCT00001637', 'NCT00001715', 'NCT00001721', 'NCT00001756', 'NCT00001762', 'NCT00001778', 'NCT00001788', 'NCT00001806', 'NCT00001844', 'NCT00001852', 'NCT00001856', 'NCT00001858', 'NCT00001859', 'NCT00001872', 'NCT00001899', 'NCT00001921', 'NCT00001975', 'NCT00003145', 'NCT00004577', 'NCT00004996', 'NCT00005655', 'NCT00006171', 'NCT00006301', 'NCT00006333', 'NCT00006436', 'NCT00007150', 'NCT00009035', 'NCT00009243', 'NCT00013533', 'NCT00013559', 'NCT00016731', 'NCT00018018', 'NCT00022971', 'NCT00023296', 'NCT00023504', 'NCT00024622', 'NCT00025714', 'NCT00025857']
    end

    def zika_studies2
      ['NCT03008122', 'NCT02979938', 'NCT02943304', 'NCT02952833', 'NCT03188731', 'NCT03443830', 'NCT02733796', 'NCT03055585', 'NCT02963909', 'NCT02916732', 'NCT03330600', 'NCT03611946', 'NCT03425149', 'NCT02794181', 'NCT03776903', 'NCT03343626', 'NCT03204409', 'NCT02996890', 'NCT03679728', 'NCT03624946', 'NCT03263195', 'NCT03206541', 'NCT01099852', 'NCT03393286', 'NCT03158233', 'NCT02810210', 'NCT03255369', 'NCT03106714', 'NCT03776695', 'NCT02856984', 'NCT03161444', 'NCT03229421', 'NCT02831699', 'NCT03110770']
    end

    def zika_studies
      [ 'NCT03611946', 'NCT03158233', 'NCT03229421', 'NCT02996890', 'NCT03106714', 'NCT02979938', 'NCT02952833', 'NCT03624946', 'NCT03679728', 'NCT03008122', 'NCT02963909', 'NCT02937233', 'NCT03425149', 'NCT02856984', 'NCT02810210', 'NCT03263195', 'NCT03393286', 'NCT02733796', 'NCT03330600', 'NCT02840487', 'NCT02916732', 'NCT02996461', 'NCT03443830', 'NCT03255369', 'NCT03776695', 'NCT03014089', 'NCT03188731', 'NCT02831699', 'NCT03161444', 'NCT03204409', 'NCT03343626', 'NCT02794181', 'NCT03776903', 'NCT02943304', 'NCT03110770', 'NCT03227601', 'NCT02874456', 'NCT03037164', 'NCT02887482', 'NCT03055585', 'NCT02741882', 'NCT01099852', 'NCT03206541', 'NCT02809443', 'NCT03078894', 'NCT03553277', 'NCT03534245', 'NCT02957344', 'NCT03631719']
    end

  end
end
