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

    has_one  :brief_summary,         :foreign_key => 'nct_id', :dependent => :delete
    has_one  :design,                :foreign_key => 'nct_id', :dependent => :delete
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
    has_many :result_contacts,       :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :sponsors,              :foreign_key => 'nct_id', :dependent => :delete_all

    def self.all_ids
      all.pluck(:nct_id)
    end

    def title_duplicated?
      Ctgov::Study.where('brief_title=?', brief_title).size > 1
    end

#   hook method
    def should_be_loaded?
      #!brief_title.include? 'Trial of device that is not approved or cleared by the U.S. FDA'
      true
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

    def gender_based
      eligibility.gender_based
    end

    def gender
      eligibility.gender
    end

  end
end
