class String
  def is_missing_the_day?
    # use this method on string representations of dates.  If only one space in the string, then the day is not provided.
    (count ' ') == 1
  end
end

module Ctgov
  class Study < ActiveRecord::Base
    self.table_name = 'ctgov.studies'
    self.primary_key = 'nct_id'

    attr_accessor :delimiters

    has_one  :brief_summary,         :foreign_key => 'nct_id', :dependent => :delete
    has_one  :design,                :foreign_key => 'nct_id', :dependent => :delete
    has_one  :detailed_description,  :foreign_key => 'nct_id', :dependent => :delete
    has_one  :eligibility,           :foreign_key => 'nct_id', :dependent => :delete
    has_one  :participant_flow,      :foreign_key => 'nct_id', :dependent => :delete
    has_one  :calculated_value,      :foreign_key => 'nct_id', :dependent => :delete

    has_many :baseline_measurements, :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :baseline_counts,       :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :browse_conditions,     :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :browse_interventions,  :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :central_contacts,      :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :conditions,            :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :countries,             :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :design_outcomes,       :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :design_groups,         :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :design_group_interventions, :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :documents,             :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :drop_withdrawals,      :foreign_key => 'nct_id', :dependent => :delete_all

    has_many :facilities,            :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :facility_contacts,     :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :facility_investigators,:foreign_key => 'nct_id', :dependent => :delete_all
    has_many :id_information,        :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :interventions,         :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :intervention_other_names, :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :ipd_information_types, :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :keywords,              :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :links,                 :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :milestones,            :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :outcomes,              :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :outcome_analysis_groups, :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :outcome_analyses,      :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :outcome_measurements,  :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :overall_officials,     :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :pending_results,       :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :references,            :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :reported_events,       :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :responsible_parties,   :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :result_agreements,     :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :result_contacts,       :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :result_groups,         :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :sponsors,              :foreign_key => 'nct_id', :dependent => :delete_all

    def new_line
      @delimiters[:new_line] || '||'
    end

    def tab
      @delimiters[:tab] || '|'
    end

    def space_char
      @delimiters[:space_char] || '%20'
    end

    def double_quote_char
      @delimiters[:double_quote_char] || '%22'
    end

    def forward_slash_char
      @delimiters[:forward_slash_char] || '%2F'
    end

    def subject
      #  should be 'LAST' when we're loading a set of quickstatements for an object.
      # Should be the study's QCode when we're creating just one quickstatement per study
      'LAST'
    end

    def create_all_quickstatements(f)
      f << 'CREATE'
      prop_codes.each{ |prop_code| f << quickstatement_for(prop_code) }
      f << " #{new_line}#{new_line}"
    end

    def self.all_ids
      all.pluck(:nct_id)
    end

    def self.get_for(id)
      where('nct_id=?', id).first.set_delimiters
    end

    def set_delimiters(args={})
      @delimiters = args[:delimiters]
      @delimiters = {:new_line=>'||', :tab=>'|', :space_char=>'%20', :double_quote_char=>'%22', :forward_slash_char=>'%2F'} if @delimiters.blank?
      #@delimiters = {:new_line=>'
  #', :tab=>'	', :space_char=>' ', :double_quote_char=>'"', :forward_slash_char=>'/'} if @delimiters.blank?
      puts @delimiters
      return self
    end

    def prop_codes
      ['Len',    # label
       'Den',    # description
       'P17',    # countries
       'P31',    # instance of
       'P248',   # publications
       'P580',   # start date
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
      ]
    end

    def quickstatement_for(prop_code)
      reg_prefix="#{prefix}#{prop_code}#{tab}"
      case prop_code
        when 'Len'
          return "#{reg_prefix}\"#{brief_title[0..244]}\""   # Label
        when 'Den'
          return "#{reg_prefix}\"clinical trial\""     # Description
        when 'P17'    # country
          return country_quickstatements
        when 'P31'    # instance of
          return "#{reg_prefix}Q30612"   # instance of a clinical trial
        when 'P248'   # publications
          return pubmed_quickstatements
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
        when 'P1050'   # conditions
          return condition_quickstatements
        when 'P1132'  # number of participants
          return "#{reg_prefix}#{enrollment}" if enrollment
        when 'P1476'  # title
          return "#{reg_prefix}en:\"#{official_title}\"" if official_title
        when 'P1813'  # acronym
          return "#{reg_prefix}en:\"#{acronym}\"" if acronym
        when 'P2899'   # min/max age
          return min_max_age_quickstatements
        when 'P3098'  # NCT ID
          return "#{reg_prefix}\"#{nct_id}\""
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
      else
        puts "unknown property:  #{prop_code}"
      end
    end

    def design_quickstatements
      return_str = ''
      return_str << 'CREATE'
      return_str << "#{new_line}#{subject}#{tab}P31#{tab}Q1438035"   # instance of research design
      return_str << "#{new_line}#{subject}#{tab}?????#{tab}en:\"#{design.intervention_for_wiki}\""
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

    def country_quickstatements
      return_str = ''
      assigned_qcodes=[]
      active_countries.each{ |country|
        qcode = Lookup::Country.qcode_for(country.name)
        if !qcode.blank? and !assigned_qcodes.include?(qcode)
          return_str << "#{new_line}#{subject}#{tab}P17#{tab}#{qcode}" if !qcode.blank?
          assigned_qcodes << qcode
        end
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
        return_str << "#{prefix}P248#{tab}#{pub_qcode}"
        # provide reference to NCBI URL
        return_str << "#{new_line}#{subject}#{tab}P854#{tab}\"https://www.ncbi.nlm.nih.gov/pubmed/?term=#{ref.pmid}\"" if !ref.pmid.blank?
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

  #  convenience methods

    def study_references
      references.select{|r|r.type!='results_reference'}
    end

    def result_references
      references.select{|r|r.type=='results_reference'}
    end

    def active_countries
      self.countries.select{ |c| c.removed != true }
    end

    def collaborators
      sponsors.where(lead_or_collaborator: 'collaborator')
    end

    def lead_sponsors
      sponsors.where(lead_or_collaborator: 'lead') if !sponsors.empty?
    end

    def minimum_age
      eligibility.minimum_age
    end

    def maximum_age
      eligibility.maximum_age
    end

    def prefix
      return "#{new_line}#{subject}#{tab}"
    end

  end
end
