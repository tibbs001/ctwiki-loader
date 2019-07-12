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
      t.string  'accepts_healthy_volunteers_indicator'
      t.string  'study_protocol_type'
      t.string  'study_subtype_code'
      t.string  'study_population_description'
      t.string  'study_model_code'
      t.string  'study_model_other_text'
      t.string  'sampling_method_code'
      t.string  'principal_investigator'
      t.string  'lead_org'
      t.integer 'minimum_target_accrual_number'
      t.integer 'number_of_arms'
      t.text    'brief_summary'
      t.text    'detail_description'
    end

    create_table 'nci.anatomic_sites' do |t|
      t.string  'nct_id'
      t.string  'name'
    end

    create_table 'nci.associated_studies' do |t|
      t.string  'nct_id'
      t.string  'study_id'
      t.string  'study_id_type'
    end

    create_table 'nci.biomarkers' do |t|
      t.string  'nct_id'
      t.string  'assay_purpose'
      t.string  'long_name'
      t.string  'name'
      t.string  'hugo_biomarker_code'
      t.string  'nci_thesaurus_concept_id'
      t.string  'eligibility_criterion'
    end

    create_table 'nci.bio_specimens' do |t|
      t.string  'nct_id'
      t.string  'f1'
      t.string  'f2'
      t.string  'f3'
      t.string  'f4'
    end

    create_table 'nci.central_contacts' do |t|
      t.string  'nct_id'
      t.string  'central_contact_email'
      t.string  'central_contact_name'
      t.string  'central_contact_phone'
      t.string  'central_contact_type'
    end

    create_table 'nci.collaborators' do |t|
      t.string  'nct_id'
      t.string  'name'
      t.string  'functional_role'
    end

    create_table 'nci.diseases' do |t|
      t.string  'nct_id'
      t.string  'disease_code'
      t.string  'inclusion_indicator'
      t.string  'lead_disease_indicator'
      t.string  'nci_thesaurus_concept_id'
      t.string  'preferred_name'
      t.string  'display_name'
    end

    create_table 'nci.disease_synonyms' do |t|
      t.string  'nct_id'
      t.string  'disease_code'
      t.string  'name'
    end

    create_table 'nci.disease_parents' do |t|
      t.string  'nct_id'
      t.string  'disease_code'
      t.string  'code'
    end

    create_table 'nci.eligibilities' do |t|
      t.string  'nct_id'
      t.string  'gender'
      t.string  'max_age'
      t.integer 'max_age_number'
      t.string  'max_age_unit'
      t.string  'min_age'
      t.integer 'min_age_number'
      t.string  'min_age_unit'
      t.integer 'max_age_in_years'
      t.integer 'min_age_in_years'
    end

    create_table 'nci.eligibility_criteria' do |t|
      t.string  'nct_id'
      t.integer 'display_order'
      t.boolean 'inclusion_indicator'
      t.text    'description'
    end

    create_table 'nci.keywords' do |t|
      t.string  'nct_id'
      t.string  'name'
    end

    create_table 'nci.maskings' do |t|
      t.string  'nct_id'
      t.string  'masking'
      t.string  'masking_allocation_code'
      t.string  'masking_role_investigator'
      t.string  'masking_role_outcome_assessor'
      t.string  'masking_role_subject'
      t.string  'masking_role_caregiver'
    end

    create_table 'nci.other_ids' do |t|
      t.string  'nct_id'
      t.string  'name'
      t.string  'value'
    end

    create_table 'nci.outcome_measures' do |t|
      t.string  'nct_id'
      t.string  'name'
      t.string  'description'
      t.string  'timeframe'
      t.string  'type_code'
    end

    create_table 'nci.phases' do |t|
      t.string  'nct_id'
      t.string  'phase'
      t.string  'phase_other_text'
      t.string  'phase_additional_qualifier_code'
    end

    create_table 'nci.primary_purposes' do |t|
      t.string  'nct_id'
      t.string  'primary_purpose_code'
      t.string  'primary_purpose_other_text'
      t.string  'primary_purpose_additional_qualifier_code'
    end

    create_table 'nci.sites' do |t|
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
      t.float   'lat',  :precision => 8, :scale => 6
      t.float   'lon',  :precision => 8, :scale => 6
    end

    #add_index 'nci.studies', :nci_id
    #add_index 'nci.studies', :nct_id
    #add_index 'nci.studies', :protocol_id

  end
end
