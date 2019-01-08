module Util
  class Exporter

    attr_accessor :study, :new_line, :tab

    def run(delimiters=nil)
      #delimiters = {:new_line=>'||', :tab=>'|'} if delimiters.blank?
      delimiters = {:new_line=>'
', :tab=>'	'} if delimiters.blank?
      @new_line = delimiters[:new_line]
      @tab = delimiters[:tab]
      File.open("public/data.txt", "w+") do |f|
        self.zika_studies[0..9].each do |id|
        #Study.all[0..9].each do |id|
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
      f << "#{new_line}LAST#{tab}P1476#{tab}en:\"#{study.design.intervention_model_description.gsub('#{new_line}','|')}\""
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
        if !qcode.blank?
          f << "#{new_line}LAST#{tab}P6153#{tab}#{qcode}" if !qcode.blank?
        else
          f << "#{new_line}LAST#{tab}P281#{tab}\"#{facility.zip}\"" if !facility.zip.blank? and facility.zip.count("a-zA-Z") == 0
        end
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
      study.conditions.each{ |condition|
        qcode = Lookup::Condition.qcode_for(condition.name)
        f << "#{new_line}LAST#{tab}P2175#{tab}#{qcode}" if !qcode.blank?
      }
    end

    def assign_country_qcodes(f)
      study.active_countries.each{ |country|
        qcode = Lookup::Country.qcode_for(country.name)
        f << "#{new_line}LAST#{tab}P17#{tab}#{qcode}" if !qcode.blank?
      }
    end

    def assign_intervention_qcodes(f)
      study.interventions.each{ |intervention|
        qcode = Lookup::Intervention.qcode_for(intervention.name)
        f << "#{new_line}LAST#{tab}P4844#{tab}#{qcode}" if !qcode.blank?
      }
    end

    def assign_pubmed_ids(f)
      study.study_references.each{ |ref|
        f << "#{new_line}LAST#{tab}P698#{tab}\"#{ref.pmid}\"" if !ref.pmid.blank?
      }
    end

    def assign_sponsor_qcodes(f)
      study.lead_sponsors.each{ |sponsor|
        qcode = Lookup::Sponsor.qcode_for(sponsor.name)
        f << "#{new_line}LAST#{tab}P859#{tab}#{qcode}" if !qcode.blank?
      }
    end

    def assign_collaborators_qcodes(f)
      study.collaborators.each{ |sponsor|
        qcode = Lookup::Sponsor.qcode_for(sponsor.name)
        f << "#{new_line}LAST#{tab}P767#{tab}#{qcode}" if !qcode.blank?
      }
    end

    def zika_studies
      ['NCT03008122', 'NCT02979938', 'NCT02943304', 'NCT02952833', 'NCT03188731', 'NCT03443830', 'NCT02733796', 'NCT03055585', 'NCT02963909', 'NCT02916732', 'NCT03330600', 'NCT03611946', 'NCT03425149', 'NCT02794181', 'NCT03776903', 'NCT03343626', 'NCT03204409', 'NCT02996890', 'NCT03679728', 'NCT03624946', 'NCT03263195', 'NCT03206541', 'NCT01099852', 'NCT03393286', 'NCT03158233', 'NCT02810210', 'NCT03255369', 'NCT03106714', 'NCT03776695', 'NCT02856984', 'NCT03161444', 'NCT03229421', 'NCT02831699', 'NCT03110770']
    end

    def other_studies
      ['NCT02629120', 'NCT02282904', 'NCT02116764', 'NCT01906541', 'NCT01855685', 'NCT01338675', 'NCT00927134', 'NCT00799071', 'NCT00778882', 'NCT00578643', 'NCT00394316', 'NCT03605199', 'NCT00001317', 'NCT00023192', 'NCT00006417', 'NCT00001765', 'NCT00001405', 'NCT00476697', 'NCT02971176', 'NCT01637194', 'NCT00492089', 'NCT00068497', 'NCT00470496', 'NCT00101348', 'NCT00089362', 'NCT01851460', 'NCT00023959', 'NCT02234934', 'NCT02231996', 'NCT02082353', 'NCT01381003', 'NCT01147042', 'NCT01063309', 'NCT03630198', 'NCT00564759', 'NCT00001280', 'NCT00397384', 'NCT00031681', 'NCT00030498', 'NCT00730314', 'NCT01806675', 'NCT01953016', 'NCT01196702', 'NCT00001476', 'NCT00325078', 'NCT02180867', 'NCT01524926', 'NCT03278912', 'NCT01598376', 'NCT02285582', 'NCT01998633', 'NCT02512679', 'NCT01319851', 'NCT00005933', 'NCT00006054', 'NCT02829853', 'NCT03557060', 'NCT03482479', 'NCT03410290', 'NCT03298061', 'NCT03169595', 'NCT03164473', 'NCT03036670', 'NCT03010436', 'NCT03004326', 'NCT02967068', 'NCT02947945', 'NCT02807103', 'NCT02728271', 'NCT02593565', 'NCT02507024', 'NCT02190942', 'NCT02190929', 'NCT02190916', 'NCT02176070', 'NCT02020889', 'NCT02006134', 'NCT01729624', 'NCT01241305', 'NCT01066208', 'NCT00751517', 'NCT00716651', 'NCT00647166', 'NCT00527566', 'NCT00424749', 'NCT00399399', 'NCT00315380', 'NCT00307671', 'NCT00307593', 'NCT00266565', 'NCT00006055', 'NCT00973947', 'NCT00898638', 'NCT00898300', 'NCT00897793', 'NCT00896896', 'NCT00616590', 'NCT00544336', 'NCT00538850', 'NCT00984074', 'NCT00090337', 'NCT00002533', 'NCT00017511', 'NCT00751816', 'NCT00006799', 'NCT01172028', 'NCT01015963', 'NCT00828516', 'NCT00415025', 'NCT00003103', 'NCT00003657', 'NCT00006036', 'NCT00002901', 'NCT00045006', 'NCT00041171', 'NCT00020579', 'NCT00019110', 'NCT00010023', 'NCT00004065', 'NCT00003565', 'NCT00001155', 'NCT01156142', 'NCT01096381', 'NCT00937417', 'NCT00896350', 'NCT00448552', 'NCT00098943', 'NCT00049296', 'NCT00023790', 'NCT00021047', 'NCT00019331', 'NCT00014456', 'NCT00002520', 'NCT02888080', 'NCT00872612', 'NCT00509665']
    end

  end
end
