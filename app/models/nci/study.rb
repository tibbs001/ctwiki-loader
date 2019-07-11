module Nci
  class Study < ActiveRecord::Base
    self.table_name = 'nci.studies'
    self.primary_key = 'nct_id'

    has_one  :bio_specimen,       :foreign_key => 'nct_id', :dependent => :destroy
    has_one  :central_contact,    :foreign_key => 'nct_id', :dependent => :destroy
    has_one  :masking,            :foreign_key => 'nct_id', :dependent => :destroy
    has_one  :phase,              :foreign_key => 'nct_id', :dependent => :destroy
    has_one  :primary_purpose,    :foreign_key => 'nct_id', :dependent => :destroy

    has_many :anatomic_sites,     :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :associated_studies, :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :biomarkers,         :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :collaborators,      :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :keywords,           :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :other_ids,          :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :outcome_measures,   :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :sites,              :foreign_key => 'nct_id', :dependent => :delete_all

    accepts_nested_attributes_for :anatomic_sites, :associated_studies, :other_ids, :outcome_measures

    def initialize(params={})
      nct_id=params['nct_id']
      puts "=======>>> bio specimen"
      params["bio_specimen"]       = Nci::BioSpecimen.new(params['bio_specimen'].merge({'nct_id'=>nct_id}))  if params['bio_specimen']
      puts "=======>>> central contact"
      params["central_contact"]    = Nci::CentralContact.new(params['central_contact'].merge({'nct_id'=>nct_id})) if params['central_contact']
      puts "=======>>> masking"
      params["masking"]            = Nci::Masking.new(params['masking'].merge({'nct_id'=>nct_id}))  if params['masking']
      puts "=======>>> phase"
      params["phase"]              = Nci::Phase.new(params['phase'].merge({'nct_id'=>nct_id}))  if params['phase']
      puts "=======>>> primary purpose"
      params["primary_purpose"]    = Nci::PrimaryPurpose.new(params['primary_purpose'].merge({'nct_id'=>nct_id}))  if params['primary_purpose']

      params["anatomic_sites"]     = params["anatomic_sites"].map {|as| Nci::AnatomicSite.new({:nct_id=>nct_id,:name=>as})} if params['anatomic_sites']
      puts "=======>>> associated_studies"
      params["associated_studies"] = params["associated_studies"].map {|as| Nci::AssociatedStudy.new(as.merge({'nct_id'=>nct_id}))}  if params['associated_studies']
      puts "=======>>> biomarker"
      params["biomarker"]          = params["biomarker"].map {|as| Nci::Biomarker.new(as.merge({'nct_id'=>nct_id}))}  if params['biomarkers']
      puts "=======>>> collaborators"
      params["collaborators"]      = params["collaborators"].map {|as| Nci::Collaborator.new(as.merge({'nct_id'=>nct_id}))}  if params['collaborators']
      puts "=======>>> keywords"
      params["keywords"]           = params["keywords"].map {|as| Nci::Keyword.new(as.merge({'nct_id'=>nct_id}))} if !params['keywords'].nil?
      puts "=======>>> other_ids"
      params["other_ids"]          = params["other_ids"].map {|as| Nci::OtherId.new(as.merge({'nct_id'=>nct_id}))}  if params['other_ids']
      puts "=======>>> outcome_mea"
      params["outcome_measures"]   = params["outcome_measures"].map {|as| Nci::OutcomeMeasure.new(as.merge({'nct_id'=>nct_id}))}  if params['outcome_measures']
      puts "=======>>> sites"
      if params['sites']
        params['sites'] = params["sites"].map {|s|
          if s['org_coordinates']
            lat=s['org_coordinates']['lat']
            lon=s['org_coordinates']['lon']
            clean_s=s.reject! { |k| k == 'org_coordinates' }
          else
            lat=lon=nil
            clean_s=s
          end
          Nci::Site.new(clean_s.merge({'nct_id'=>nct_id,'lat'=>lat,'lon'=>lon}))
        }
      end
      super(params)
    end

    def self.all_ids
      all.pluck(:nct_id)
    end

    def self.populate
      data = JSON.parse(File.read("public/nci-data.json"))['trials']
      data.each{ |study_data| Nci::Study.create(study_data) if study_data }
    end

    def self.json1
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
       "brief_summary"=>
        "This phase III ALCHEMIST trial studies how well crizotinib works in treating patients with stage IB-IIIA non-small cell lung cancer that has been removed by surgery and has a mutation in a protein called anaplastic lymphoma kinase (ALK). Mutations, or changes, in ALK can make it very active and important for tumor cell growth and progression. Crizotinib may stop the growth of tumor cells by blocking the ALK protein from working. Crizotinib may be an effective treatment for patients with non-small cell lung cancer and an ALK fusion mutation.",
    "detail_description"=>
     "PRIMARY OBJECTIVES:\r\n" +
     "I. To evaluate whether adjuvant therapy with crizotinib will result in improved disease-free survival (DFS) for patients with stage IB >= 4cm, II and IIIA, ALK-positive non-small cell lung cancer (NSCLC) following surgical resection.\r\n" +
     "\r\n" +
     "SECONDARY OBJECTIVES:\r\n" +
     "I. To evaluate and compare overall survival (OS) associated with crizotinib.\r\n" +
     "II. To evaluate the safety profile of crizotinib when given in the adjuvant therapy setting.\r\n" +
     "III. To collect tumor tissue and blood specimens for future research.\r\n" +
     "\r\n" +
     "OUTLINE: Patients are randomized to 1 of 2 treatment arms.\r\n" +
     "\r\n" +
     "ARM A: Patients receive crizotinib orally (PO) twice daily (BID) on days 1-21. Treatment repeats every 21 days for up to 2 years in the absence of disease progression or unacceptable toxicity.\r\n" +
     "\r\n" +
     "ARM B: Patients undergo observation.\r\n" +
     "\r\n" +
     "After completion of study treatment, patients are followed up every 6 months if < 4 or 5 years from study entry, and every 12 months if 5-10 or 6-10 years from study entry.",
    "classification_code"=>"Efficacy",
    "interventional_model"=>"Parallel",
    "accepts_healthy_volunteers_indicator"=>"NO",
    "study_protocol_type"=>"Interventional",
    "study_subtype_code"=>nil,
    "study_population_description"=>nil,
    "study_model_code"=>nil,
    "study_model_other_text"=>nil,
    "sampling_method_code"=>nil,
    "bio_specimen"=>{"f1"=>"bio_specimen_description", "f2"=>nil, "f3"=>"bio_specimen_retention_code", "f4"=>nil},
    "primary_purpose"=>{"primary_purpose_code"=>"TREATMENT", "primary_purpose_other_text"=>nil, "primary_purpose_additional_qualifier_code"=>nil},
    "phase"=>{"phase"=>"III", "phase_other_text"=>nil, "phase_additional_qualifier_code"=>"NO"},
    "masking"=>
       {"masking"=>"DOUBLE_BLIND",
        "masking_allocation_code"=>"Randomized Controlled Trial",
        "masking_role_investigator"=>nil,
        "masking_role_outcome_assessor"=>nil,
        "masking_role_subject"=>nil,
        "masking_role_caregiver"=>nil},
      }
    end

    def self.json3
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
    "official_title"=>
     "A Randomized Phase III Trial for Surgically Resected Early Stage Non-Small Cell Lung Cancer: Crizotinib versus Observation for Patients with Tumors Harboring the Anaplastic Lymphoma Kinase (ALK) Fusion Protein",
    "acronym"=>nil,
    "brief_summary"=>
     "This phase III ALCHEMIST trial studies how well crizotinib works in treating patients with stage IB-IIIA non-small cell lung cancer that has been removed by surgery and has a mutation in a protein called anaplastic lymphoma kinase (ALK). Mutations, or changes, in ALK can make it very active and important for tumor cell growth and progression. Crizotinib may stop the growth of tumor cells by blocking the ALK protein from working. Crizotinib may be an effective treatment for patients with non-small cell lung cancer and an ALK fusion mutation.",
    "detail_description"=>
     "PRIMARY OBJECTIVES:\r\n" +
     "I. To evaluate whether adjuvant therapy with crizotinib will result in improved disease-free survival (DFS) for patients with stage IB >= 4cm, II and IIIA, ALK-positive non-small cell lung cancer (NSCLC) following surgical resection.\r\n" +
     "\r\n" +
     "SECONDARY OBJECTIVES:\r\n" +
     "I. To evaluate and compare overall survival (OS) associated with crizotinib.\r\n" +
     "II. To evaluate the safety profile of crizotinib when given in the adjuvant therapy setting.\r\n" +
     "III. To collect tumor tissue and blood specimens for future research.\r\n" +
     "\r\n" +
     "OUTLINE: Patients are randomized to 1 of 2 treatment arms.\r\n" +
     "\r\n" +
     "ARM A: Patients receive crizotinib orally (PO) twice daily (BID) on days 1-21. Treatment repeats every 21 days for up to 2 years in the absence of disease progression or unacceptable toxicity.\r\n" +
     "\r\n" +
     "ARM B: Patients undergo observation.\r\n" +
     "\r\n" +
     "After completion of study treatment, patients are followed up every 6 months if < 4 or 5 years from study entry, and every 12 months if 5-10 or 6-10 years from study entry.",
    "classification_code"=>"Efficacy",
    "study_subtype_code"=>nil,
    "study_population_description"=>nil,
    "study_model_code"=>nil,
    "study_model_other_text"=>nil,
    "sampling_method_code"=>nil,
    "interventional_model"=>"Parallel",
    "accepts_healthy_volunteers_indicator"=>"NO",
    "study_protocol_type"=>"Interventional",
    "bio_specimen"=>{"f1"=>"bio_specimen_description", "f2"=>nil, "f3"=>"bio_specimen_retention_code", "f4"=>nil},
    "primary_purpose"=>{"primary_purpose_code"=>"TREATMENT", "primary_purpose_other_text"=>nil, "primary_purpose_additional_qualifier_code"=>nil},
    "phase"=>{"phase"=>"III", "phase_other_text"=>nil, "phase_additional_qualifier_code"=>"NO"},
    "masking"=>
     {"masking"=>"DOUBLE_BLIND",
      "masking_allocation_code"=>"Randomized Controlled Trial",
      "masking_role_investigator"=>nil,
      "masking_role_outcome_assessor"=>nil,
      "masking_role_subject"=>nil,
      "masking_role_caregiver"=>nil},
    "principal_investigator"=>"David Eric Gerber",
    "central_contact"=>{"central_contact_email"=>nil, "central_contact_name"=>nil, "central_contact_phone"=>nil, "central_contact_type"=>nil},
    "lead_org"=>"ECOG-ACRIN Cancer Research Group",
    "collaborators"=>[{"name"=>"National Cancer Institute", "functional_role"=>"FUNDING_SOURCE"}],
    "sites"=>
      [{"contact_email"=>nil,
        "contact_name"=>"Site Public Contact",
        "contact_phone"=>"610-250-4000",
        "recruitment_status"=>"ACTIVE",
        "recruitment_status_date"=>"2019-02-27",
        "local_site_identifier"=>"",
        "org_address_line_1"=>"250 South 21st Street",
        "org_address_line_2"=>nil,
        "org_city"=>"Easton",
        "org_country"=>"United States",
        "org_email"=>nil,
        "org_family"=>nil,
        "org_fax"=>nil,
        "org_name"=>"Easton Hospital",
        "org_to_family_relationship"=>nil,
        "org_phone"=>"610-250-4000",
        "org_postal_code"=>"18042",
        "org_state_or_province"=>"PA",
        "org_status"=>"ACTIVE",
        "org_status_date"=>"2015-07-28",
        "org_tty"=>nil,
        "org_va"=>false,
        "org_coordinates"=>{"lat"=>40.6369, "lon"=>-75.2272}},
       {"contact_email"=>nil,
        "contact_name"=>"Site Public Contact",
        "contact_phone"=>"610-431-5297",
        "recruitment_status"=>"ACTIVE",
        "recruitment_status_date"=>"2019-04-09",
        "local_site_identifier"=>"",
        "org_address_line_1"=>"701 East Marshall Street",
        "org_address_line_2"=>nil,
        "org_city"=>"West Chester",
        "org_country"=>"United States",
        "org_email"=>nil,
        "org_family"=>nil,
        "org_fax"=>nil,
        "org_name"=>"Chester County Hospital",
        "org_to_family_relationship"=>nil,
        "org_phone"=>"610-431-5297",
        "org_postal_code"=>"19380",
        "org_state_or_province"=>"PA",
        "org_status"=>"ACTIVE",
        "org_status_date"=>"2008-12-31",
        "org_tty"=>nil,
        "org_va"=>false,
        "org_coordinates"=>{"lat"=>39.9842, "lon"=>-75.6084}},
      ]}
    end

    def self.json2
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
    "official_title"=>
     "A Randomized Phase III Trial for Surgically Resected Early Stage Non-Small Cell Lung Cancer: Crizotinib versus Observation for Patients with Tumors Harboring the Anaplastic Lymphoma Kinase (ALK) Fusion Protein",
    "acronym"=>nil,
    "brief_summary"=>
     "This phase III ALCHEMIST trial studies how well crizotinib works in treating patients with stage IB-IIIA non-small cell lung cancer that has been removed by surgery and has a mutation in a protein called anaplastic lymphoma kinase (ALK). Mutations, or changes, in ALK can make it very active and important for tumor cell growth and progression. Crizotinib may stop the growth of tumor cells by blocking the ALK protein from working. Crizotinib may be an effective treatment for patients with non-small cell lung cancer and an ALK fusion mutation.",
    "detail_description"=>
     "PRIMARY OBJECTIVES:\r\n" +
     "I. To evaluate whether adjuvant therapy with crizotinib will result in improved disease-free survival (DFS) for patients with stage IB >= 4cm, II and IIIA, ALK-positive non-small cell lung cancer (NSCLC) following surgical resection.\r\n" +
     "\r\n" +
     "SECONDARY OBJECTIVES:\r\n" +
     "I. To evaluate and compare overall survival (OS) associated with crizotinib.\r\n" +
     "II. To evaluate the safety profile of crizotinib when given in the adjuvant therapy setting.\r\n" +
     "III. To collect tumor tissue and blood specimens for future research.\r\n" +
     "\r\n" +
     "OUTLINE: Patients are randomized to 1 of 2 treatment arms.\r\n" +
     "\r\n" +
     "ARM A: Patients receive crizotinib orally (PO) twice daily (BID) on days 1-21. Treatment repeats every 21 days for up to 2 years in the absence of disease progression or unacceptable toxicity.\r\n" +
     "\r\n" +
     "ARM B: Patients undergo observation.\r\n" +
     "\r\n" +
     "After completion of study treatment, patients are followed up every 6 months if < 4 or 5 years from study entry, and every 12 months if 5-10 or 6-10 years from study entry.",
    "classification_code"=>"Efficacy",
    "interventional_model"=>"Parallel",
    "accepts_healthy_volunteers_indicator"=>"NO",
    "study_protocol_type"=>"Interventional",
    "study_subtype_code"=>nil,
    "study_population_description"=>nil,
    "study_model_code"=>nil,
    "study_model_other_text"=>nil,
    "sampling_method_code"=>nil,
    "bio_specimen"=>{"f1"=>"bio_specimen_description", "f2"=>nil, "f3"=>"bio_specimen_retention_code", "f4"=>nil},
    "primary_purpose"=>{"primary_purpose_code"=>"TREATMENT", "primary_purpose_other_text"=>nil, "primary_purpose_additional_qualifier_code"=>nil},
    "phase"=>{"phase"=>"III", "phase_other_text"=>nil, "phase_additional_qualifier_code"=>"NO"},
    "masking"=>
     {"masking"=>"DOUBLE_BLIND",
      "masking_allocation_code"=>"Randomized Controlled Trial",
      "masking_role_investigator"=>nil,
      "masking_role_outcome_assessor"=>nil,
      "masking_role_subject"=>nil,
      "masking_role_caregiver"=>nil},
    "principal_investigator"=>"David Eric Gerber",
    "central_contact"=>{"central_contact_email"=>nil, "central_contact_name"=>nil, "central_contact_phone"=>nil, "central_contact_type"=>nil},
    "lead_org"=>"ECOG-ACRIN Cancer Research Group",
    "collaborators"=>[{"name"=>"National Cancer Institute", "functional_role"=>"FUNDING_SOURCE"}],
        }
    end
  end
end
