class String
  def is_missing_the_day?
    # use this method on string representations of dates.  If only one space in the string, then the day is not provided.
    (count ' ') == 1
  end
end

module Ctgov
class Study < ActiveRecord::Base
  self.table_name = 'ctgov.studies'

  attr_accessor :xml, :with_related_records, :with_related_organizations

  scope :started_between, lambda {|sdate, edate| where("start_date >= ? AND created_at <= ?", sdate, edate )}
  scope :changed_since,   lambda {|cdate| where("last_changed_date >= ?", cdate )}
  scope :completed_since, lambda {|cdate| where("completion_date >= ?", cdate )}
  scope :sponsored_by,    lambda {|agency| joins(:sponsors).where("sponsors.agency LIKE ?", "#{agency}%")}
  scope :with_one_to_ones,   -> { joins(:eligibility, :brief_summary, :design, :detailed_description) }
  scope :with_organizations, -> { joins(:sponsors, :facilities, :central_contacts, :responsible_parties) }
  self.primary_key = 'nct_id'

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

  def self.all_ids
    all.pluck(:nct_id)
  end

  def quickstatement_for(prop_code, prefix)
    case prop_code
      when 'Len'
        return "#{prefix}\"#{brief_title[0..244]}\""   # Label
      when 'Den'
        return "#{prefix}\"clinical trial\""     # Description
      when 'P31'
        return "#{prefix}Q30612"   # instance of a clinical trial
      when 'P3098'  # NCT ID
        return "#{prefix}\"#{nct_id}\""
      when 'P1476'  # title
        return "#{prefix}en:\"#{official_title}\"" if official_title
      when 'P1813'  # acronym
        return "#{prefix}en:\"#{acronym}\"" if acronym
      when 'P1132'  # number of participants
        return "#{prefix}#{enrollment}" if enrollment
      when 'P6099'  # source_entity phase
        return nil if phase.blank?
        return_str=''
        return_str << "#{prefix}Q42824069" if phase.include? '1'
        return_str << "#{prefix}Q42824440" if phase.include? '2'
        return_str << "#{prefix}Q42824827" if phase.include? '3'
        return_str << "#{prefix}Q42825046" if phase.include? '4'
        return return_str
      when 'P580'   # start date
        return "#{prefix}+#{quickstatement_date(start_date, start_month_year)}" if start_date
      when 'P582'   # primary completion date
        return "#{prefix}+#{quickstatement_date(primary_completion_date, primary_completion_month_year)}" if primary_completion_date
    else
      puts "unknown property:  #{prop_code}"
    end
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
end

end
