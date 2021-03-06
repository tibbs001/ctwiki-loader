module QsCreator
  class Study
    include Util::QuickstatementExtension
    attr_accessor :lookup_mgr, :study

    def method_missing(name, *args, &block)
      # if QsCreator can't respond to a method, forward it along to it's study
      if args.empty?
        study.send(name.to_s)
      else
        study.send(name.to_s, *[args])
      end
    end

    def get_for(id)
      @study = Ctgov::Study.where('nct_id=?', id).first
    end

    def prop_codes
      ['Len',    # English label
       'Den',    # English description
       'Lnl',    # Dutch label
       'Dnl',    # Dutch description
       'Les',    # Spanish label
       'Des',    # Spanish description
       'P17',    # countries
       'P31',    # instance of
       'P248',   # publications
       'P580',   # start date
       'P8363',  # study type
       'P582',   # primary completion date
       'P767',   # collaborators
       'P859',   # sponsors
       'P921',   # keywords
       'P1050',  # conditions
       'P1132',  # number of participants
       'P1476',  # title
       'P1813',  # acronym
       'P2899',  # min/max age
       'P3098',  # nct id
       'P4844',  # interventions
       'P6099',  # phase
       'P6153',  # facility
       'P8005',  # recruitment status (overall_status)
       'P21',    # gender
      ]
    end

    def quickstatement_with_old_subject(prop_code)
      # assume object contains value currently in wikidata
      "#{subject}#{tab}#{prop_code}#{tab}#{object}"
    end

    def quickstatement_with_new_subject(prop_code)
      quickstatement_for(prop_code)
    end

    def start_date_qualifier_suffix
      "#{tab}P580#{tab}#{quickstatement_date(last_update_submitted_date)}"
    end

    def quickstatement_for(prop_code)
      reg_prefix="#{prefix}#{prop_code}#{tab}"
      case prop_code
        when 'Len'
          return compose_label(reg_prefix)
        when 'Den'
          return "#{reg_prefix}\"clinical trial\""     # English Description
        when 'Dnl'
          return "#{reg_prefix}\"klinisch onderzoek\"" # Dutch Description
        when 'Des'
          return "#{reg_prefix}\"ensayo clínico\""     # Spanish Description
        when 'P17'    # country
          return country_quickstatements
        when 'P31'    # instance of
          return "#{reg_prefix}Q30612"   # instance of a clinical trial
        when 'P248'   # publications
          # until we determine the property we should use for this, comment it out.
          #return pubmed_quickstatements
        when 'P580'   # start date
          return "#{reg_prefix}+#{quickstatement_date(start_date, start_month_year)}" if start_date
        when 'P582'   # primary completion date
          return "#{reg_prefix}+#{quickstatement_date(primary_completion_date, primary_completion_month_year)}" if primary_completion_date
        when 'P767'   # collaborators
          return collaborator_quickstatements
        when 'P859'   # sponsors
          return sponsor_quickstatements
        when 'P921'   # keywords
          return keyword_quickstatements
        when 'P1343'
          return pubmed_quickstatements
        when 'P1050'   # conditions
          return condition_quickstatements
        when 'P1132'  # number of participants
          return "#{reg_prefix}#{enrollment}" if enrollment
        when 'P8363'  # study type
          return "#{reg_prefix}Q78089383" if study_type == 'Interventional'
          return "#{reg_prefix}Q78089804" if study_type == 'Observational'
          return "#{reg_prefix}Q407954"   if study_type == 'Expanded Access'
        when 'P1476'  # title
          return "#{reg_prefix}en:\"#{official_title}\"" if official_title
        when 'P1813'  # acronym
          return "#{reg_prefix}en:\"#{acronym}\"" if acronym
        when 'P2899'   # min/max age
          return min_max_age_quickstatements
        when 'P3098'  # NCT ID
          return "#{reg_prefix}\"#{nct_id}\""
        when 'P6153'   # facilities
          return facility_quickstatements
        when 'P4844'   # interventions
          return intervention_quickstatements
        when 'P6099'  # phase
          return nil if phase.blank?
          return_str=''
          return_str << "#{reg_prefix}Q42824069" if phase.include? '1'
          return_str << "#{reg_prefix}Q42824440" if phase.include? '2'
          return_str << "#{reg_prefix}Q42824827" if phase.include? '3'
          return_str << "#{reg_prefix}Q42825046" if phase.include? '4'
          return return_str
        when 'P8005'  # overall_status
          return_str=''
          return nil if overall_status.blank?
          case overall_status
          when 'Active, not recruiting'
            return_str << "#{reg_prefix}Q76649790"
          when  'Suspended'
            return_str << "#{reg_prefix}Q76649855"
          when 'Recruiting'
            return_str << "#{reg_prefix}Q76649708"
          when  'Completed'
            return_str << "#{reg_prefix}Q76651189"
          when 'Withdrawn'
            return_str << "#{reg_prefix}Q76650124"
          when 'Terminated'
            return_str << "#{reg_prefix}Q76649944"
          when 'Not yet recruiting'
            return_str << "#{reg_prefix}Q76649614"
          when 'Available'
            return_str << "#{reg_prefix}Q92334830"
          when 'Approved for marketing'
            return_str << "#{reg_prefix}Q92334785"
          when 'Enrolling by invitation'
            return_str << "#{reg_prefix}Q92331923"
          when 'No longer available'
            return_str << "#{reg_prefix}Q92334851"
          when 'Unknown status'
            return_str << "#{reg_prefix}Q76651279"
          when 'Withheld'
            return_str << "#{reg_prefix}Q92335256"
          end
          return return_str
      else
        puts "unknown property:  #{prop_code}"
      end
    end

    def compose_label(reg_prefix)
      if title_duplicated?
        # add the start date to the label if more than one study has this title
        suffix = start_date.strftime("%Y-%m-%d") if start_date
        suffix = study_first_submitted_date.strftime("%Y-%m-%d") if !suffix && study_first_submitted_date
        label = "#{reg_prefix}\"#{brief_title[0..233]} (#{suffix})\""
      else
        label = "#{reg_prefix}\"#{brief_title[0..244]}\""
      end
      return label
    end

    def country_quickstatements
      return_str = ''
      assigned_qcodes=[]
      active_countries.each{ |country|
        qcode = Lookup::Country.qcode_for(country.name)
        assigned_qcodes << qcode
        return_str << "#{new_line}#{subject}#{tab}P17#{tab}#{qcode}" if !qcode.blank?
      }
      return return_str
    end

    def design_quickstatements
      return_str = ''
      return_str << 'CREATE'
      return_str << "#{new_line}#{subject}#{tab}P31#{tab}Q1438035"   # instance of research design
      return_str << "#{new_line}#{subject}#{tab}?????#{tab}en:\"#{design.intervention_for_wiki}\""
      return return_str
    end

    def main_orgs_quickstatements
      return_str = ''
      overall_official.each{ |org|
        qcode = Lookup::Organization.qcode_for(org.affiliation)
        return_str << "#{new_line}#{subject}#{tab}P6153#{tab}#{qcode}" if !qcode.blank?
      }
      return return_str
    end

    def facility_quickstatements
      return_str = ''
      facilities.each{ |facility|
        qcode = Lookup::Organization.qcode_for(facility.name)
        return_str << "#{new_line}#{subject}#{tab}P6153#{tab}#{qcode}" if !qcode.blank?
      }
      return return_str
    end

    def keyword_quickstatements
      return_str = ''
      keywords.each{ |keyword|
        qcode = Lookup::Keyword.qcode_for(keyword.name)
        #topics are: Q200801
        return_str << "#{new_line}#{subject}#{tab}P921#{tab}#{qcode}" if !qcode.blank?
      }
      return return_str
    end

    def intervention_quickstatements
      return_str = ''
      assigned_qcodes=[]
      interventions = browse_interventions.pluck(:downcase_mesh_term).uniq
      interventions.each{ |intervention|
        qcode = Lookup::Intervention.qcode_for(intervention)
        if !qcode.blank? and !assigned_qcodes.include?(qcode)
          return_str << "#{new_line}#{subject}#{tab}P4844#{tab}#{qcode}" if !qcode.blank?
          assigned_qcodes << qcode
        end
      }
      return return_str
    end

    def sponsor_quickstatements
      return_str = ''
      already_assigned_to_this_study=[]
      lead_sponsors.each{ |sponsor|
        qcode = Lookup::Sponsor.qcode_for(sponsor.name)
        if !qcode.blank? and !already_assigned_to_this_study.include?(qcode)
          return_str << "#{new_line}#{subject}#{tab}P859#{tab}#{qcode}" if !qcode.blank?
          already_assigned_to_this_study << qcode
        end
      }
      return return_str
    end

    def collaborator_quickstatements
      return_str = ''
      already_assigned_to_this_study=[]
      collaborators.each{ |sponsor|
        qcode = Lookup::Sponsor.qcode_for(sponsor.name)
        if !qcode.blank? and !already_assigned_to_this_study.include?(qcode)
          return_str << "#{new_line}#{subject}#{tab}P767#{tab}#{qcode}" if !qcode.blank?
          already_assigned_to_this_study << qcode
        end
      }
      return return_str
    end

    def pubmed_quickstatements
      return_str = ''
      result_references.each {|ref|
        pub_qcode = Lookup::Publication.qcode_for(ref.pmid)
        # Link study to pub
        return_str << "#{prefix}P1343#{tab}#{pub_qcode}"
        # provide reference to NCBI URL
        #return_str << "#{new_line}#{subject}#{tab}P854#{tab}\"https://www.ncbi.nlm.nih.gov/pubmed/?term=#{ref.pmid}\"" if !ref.pmid.blank?
      }
      return return_str
    end

    def min_max_age_quickstatements
      # year/month unit is identified by appending 'U' to the integer of the year or month Q-value, and
      # tacking it onto the end of the actual value
      min = minimum_age.split(' ')
      max = maximum_age.split(' ')

      return_str = ''
      return_str << "#{prefix}P2899#{tab}#{min[0]}U577"  if min[1] && min[1].downcase == 'years'
      return_str << "#{prefix}P4135#{tab}#{max[0]}U577"  if max[1] && max[1].downcase == 'years'
      return_str << "#{prefix}P2899#{tab}#{min[0]}U5151" if min[1] && min[1].downcase == 'months'
      return_str << "#{prefix}P4135#{tab}#{max[0]}U5151" if max[1] && max[1].downcase == 'months'
      return return_str
    end

    def condition_quickstatements
      reg_prefix="#{prefix}P1050#{tab}"
      assigned_qcodes=[]
      return_str = ''
      conditions = browse_conditions.pluck(:downcase_mesh_term).uniq
      conditions.each{ |condition|
        qcode = Lookup::Condition.qcode_for(condition)
        if !qcode.blank? and !assigned_qcodes.include?(qcode)
          return_str << "#{reg_prefix}#{qcode}"
          assigned_qcodes << qcode
        end
      }
      return return_str
    end

  end
end
