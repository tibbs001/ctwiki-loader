module Nci
  class Study < ActiveRecord::Base
    self.table_name = 'nci.studies'
    self.primary_key = 'nct_id'

    has_many :anatomic_sites, :dependent => :delete_all
    has_many :associated_studies, :dependent => :delete_all
    has_many :other_ids, :dependent => :delete_all
    has_many :outcome_measures, :dependent => :delete_all

    accepts_nested_attributes_for :anatomic_sites, :associated_studies, :other_ids, :outcome_measures

    def initialize(params={})
      nct_id=params['nct_id']
      params["anatomic_sites"]     = params["anatomic_sites"].map {|as| Nci::AnatomicSite.new(as)}  if params['anatomic_sites']
      params["associated_studies"] = params["associated_studies"].map {|as| Nci::AssociatedStudy.new(as)}  if params['associated_studies']
      params["other_ids"]          = params["other_ids"].map {|as| Nci::OtherId.new(as.merge({'nct_id'=>nct_id}))}  if params['other_ids']
      params["outcome_measures"]   = params["outcome_measures"].map {|as| Nci::OutcomeMeasure.new(as.merge({'nct_id'=>nct_id}))}  if params['outcome_measures']
      super(params)
    end

    def self.all_ids
      all.pluck(:nct_id)
    end

    def self.populate
      #data = JSON.parse(File.read("public/nci-data.json"))['trials']
      data = self.sample_json
      Nci::Study.create(data)
    end

    def self.sample_json
      {"nci_id"=>"NCI-2014-01507",
        "nct_id"=>"NCT02201992",
        "protocol_id"=>"E4512",
        "ccr_id"=>nil,
        "ctep_id"=>"E4512",
        "dcp_id"=>nil,
        "other_ids"=>[{"name"=>"Study Protocol Other Identifier", "value"=>"s16-02072"}],
        "associated_studies"=>[{"study_id"=>"NCI-2014-01509", "study_id_type"=>"NCI"}],
      }
    end

    def self.sample_json2
      {"nci_id"=>"NCI-2014-01507",
       "nct_id"=>"NCT02201992",
       "protocol_id"=>"E4512",
       "ccr_id"=>nil,
       "ctep_id"=>"E4512",
       "dcp_id"=>nil,
       "other_ids"=>[{"name"=>"Study Protocol Other Identifier", "value"=>"s16-02072"}],
       "associated_studies"=>[{"study_id"=>"NCI-2014-01509", "study_id_type"=>"NCI"}],
       "outcome_measures"=>
        [{"name"=>"Overall survival (OS)",
          "description"=>
           "Distribution will be estimated using the Kaplan-Meier method, and Cox proportional hazards models will be used to estimate the treatment hazard ratios. Other comparisons of groups will be made using the logrank test and Cox modeling. Point estimates will be accompanied by the corresponding 90% confidence intervals.",
          "timeframe"=>"The time from randomization to death from any cause, assessed up to 10 years",
          "type_code"=>"SECONDARY"},
         {"name"=>
           "Toxicity rates, determined using the Common Terminology Criteria for Adverse Events (CTCAE) version (v)4.0 (Starting April 1, 2018 CTCAE v5 will be used for Cancer Therapy Evaluation Program adverse events reporting)",
          "description"=>
           "Toxicity rates will be compared using Fisher’s exact tests with a one-sided type I error rate of 5%; multivariable logistic regression modeling will be used to adjust for the effect of any covariates that are associated with these categorical outcomes.",
          "timeframe"=>"Up to 10 years",
          "type_code"=>"SECONDARY"},
         {"name"=>"Disease free survival (DFS)",
          "description"=>
           "Distribution will be estimated using the Kaplan-Meier method, and Cox proportional hazards models will be used to estimate the treatment hazard ratios. The primary comparison of DFS will use a logrank test stratified on the randomization stratification factors with a one-sided type I error rate of 5%. Other comparisons of groups will be made using the logrank test and Cox modeling. Point estimates will be accompanied by the corresponding 90% confidence intervals.",
          "timeframe"=>
           "The time from randomization to the earliest event defined as: disease recurrence, any new lung cancer (even in the opposite lung), or death from any cause at any known point in time, assessed up to 10 years",
          "type_code"=>"PRIMARY"}],
       "amendment_date"=>"2019-02-26T00:00:00",
       "current_trial_status"=>"Active",
       "current_trial_status_date"=>"2014-08-18",
       "start_date"=>"2014-08-18",
       "start_date_type_code"=>"ACTUAL",
       "completion_date"=>nil,
       "completion_date_type_code"=>nil,
       "record_verification_date"=>"2019-03-14",
       "brief_title"=>
        "Crizotinib in Treating Patients with Stage IB-IIIA Non-small Cell Lung Cancer That Has Been Removed by Surgery and ALK Fusion Mutations (An ALCHEMIST Treatment Trial)",
       "official_title"=> "A Randomized Phase III Trial for Surgically Resected Early Stage Non-Small Cell Lung Cancer: Crizotinib versus Observation for Patients with Tumors Harboring the Anaplastic Lymphoma Kinase (ALK) Fusion Protein",
       "acronym"=>'yyy',
      }
    end

    def self.sample_json3
      {"nci_id"=>"NCI-2014-01507",
       "nct_id"=>"NCT02201992",
       "protocol_id"=>"E4512",
       "ccr_id"=>nil,
       "ctep_id"=>"E4512",
       "dcp_id"=>nil,
       "other_ids"=>[{"name"=>"Study Protocol Other Identifier", "value"=>"s16-02072"}],
       "associated_studies"=>[{"study_id"=>"NCI-2014-01509", "study_id_type"=>"NCI"}],
       "amendment_date"=>"2019-02-26T00:00:00",
       "current_trial_status"=>"Active",
       "current_trial_status_date"=>"2014-08-18",
       "start_date"=>"2014-08-18",
       "start_date_type_code"=>"ACTUAL",
       "completion_date"=>nil,
       "completion_date_type_code"=>nil,
       "record_verification_date"=>"2019-03-14",
       "brief_title"=>
        "Crizotinib in Treating Patients with Stage IB-IIIA Non-small Cell Lung Cancer That Has Been Removed by Surgery and ALK Fusion Mutations (An ALCHEMIST Treatment Trial)",
       "official_title"=> "A Randomized Phase III Trial for Surgically Resected Early Stage Non-Small Cell Lung Cancer: Crizotinib versus Observation for Patients with Tumors Harboring the Anaplastic Lymphoma Kinase (ALK) Fusion Protein",
       "acronym"=>'yyy',
      }
    end
  end
end
