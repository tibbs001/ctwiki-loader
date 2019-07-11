class CreateNciTables < ActiveRecord::Migration
  def change

    create_table 'nci.studies' do |t|
      t.string  'nci_id'
      t.string  'nct_id'
      t.string  'protocol_id'
      t.string  'ccr_id'
      t.string  'ctep_id'
      t.string  'dcp_id'
      t.string  'current_trial_status'
      t.date    'current_trial_status_date'
      t.date    'start_date'
      t.string  'start_date_type_code'
      t.date    'completion_date'
      t.string  'completion_date_type_code'
      t.date    'amendment_date'
      t.date    'record_verification_date'
      t.string  'brief_title'
      t.string  'official_title'
      t.string  'acronym'
      t.string  'classification_code'
      t.string  'interventional_model'
      t.string  'accepts_helth_volunteers_indicator'
      t.string  'study_protocol_type'
      t.string  'study_subtype_code'
      t.string  'study_population_description'
      t.string  'study_model_code'
      t.string  'study_model_other_text'
      t.string  'sampling_method_code'
      t.string  'principal_investigator'
      t.string  'lead_org'
      t.integer 'minimum_target_accural_number'
      t.integer 'number_of_arms'
    end

    create_table 'nci.other_ids' do |t|
      t.belongs_to :study, index: true
      t.string  'nct_id'
      t.string  'name'
      t.string  'value'
    end

    create_table 'nci.associated_studies' do |t|
      t.belongs_to :study, index: true
      t.string  'nct_id'
      t.string  'study_id'
      t.string  'study_id_type'
    end

    create_table 'nci.anatomic_sites' do |t|
      t.belongs_to :study, index: true
      t.string  'nct_id'
      t.string  'name'
    end

    create_table 'nci.diseases' do |t|
      t.belongs_to :study, index: true
      t.string  'nct_id'
      t.string  'disease_code'
      t.string  'inclusion_indicator'
      t.string  'lead_disease_indicator'
      t.string  'nci_thesaurus_concept_id'
      t.string  'preferred_name'
    end

    create_table 'nci.biomarkers' do |t|
      t.belongs_to :study, index: true
      t.string  'nct_id'
      t.string  'assay_purpose'
      t.string  'long_name'
      t.string  'name'
      t.string  'hugo_biomarker_code'
      t.string  'nci_thesaurus_concept_id'
      t.string  'eligibility_criterion'
    end

    create_table 'nci.maskings' do |t|
      t.belongs_to :study, index: true
      t.string  'nct_id'
      t.string  'allocation_code'
      t.string  'role_investigator'
      t.string  'role_outcome_assessor'
      t.string  'role_subject'
      t.string  'role_caregiver'
    end

    create_table 'nci.central_contacts' do |t|
      t.belongs_to :study, index: true
      t.string  'nct_id'
      t.string  'contact_type'
      t.string  'email'
      t.string  'name'
      t.string  'phone'
    end

    create_table 'nci.collaborators' do |t|
      t.belongs_to :study, index: true
      t.string  'nct_id'
      t.string  'name'
      t.string  'functional_role'
    end

    create_table 'nci.sites' do |t|
      t.belongs_to :study, index: true
      t.string  'nct_id'
      t.string  'contact_email'
      t.string  'contact_name'
      t.string  'contact_phone'
      t.string  'recruitment_status'
      t.date    'recruitment_status_date'
      t.string  'local_site_identifier'
      t.string  'org_address_line_1'
      t.string  'org_address_line_2'
      t.string  'org_city'
      t.string  'org_country'
      t.string  'org_email'
      t.string  'org_family'
      t.string  'org_fax'
      t.string  'org_name'
      t.string  'org_to_family_relationship'
      t.string  'org_phone'
      t.string  'org_postal_code'
      t.string  'org_state_or_province'
      t.string  'org_status'
      t.date    'org_status_date'
      t.string  'org_tty'
      t.string  'org_va'
    end

    create_table 'nci.phases' do |t|
      t.belongs_to :study, index: true
      t.string  'nct_id'
      t.string  'name'
      t.string  'other_text'
      t.string  'additional_qualifier'
    end

    create_table 'nci.outcome_measures' do |t|
      t.belongs_to :study, index: true
      t.string  'nct_id'
      t.string  'name'
      t.string  'description'
      t.string  'timeframe'
      t.string  'type_code'
    end

    #add_index 'nci.studies', :nci_id
    #add_index 'nci.studies', :nct_id
    #add_index 'nci.studies', :protocol_id

  end
end
