class CreatePublicationTable < ActiveRecord::Migration

  def change

    create_table 'pubmed.publications' do |t|
      t.string  'pmid'
      t.string  'issn'
      t.string  'volume'
      t.string  'issue'
      t.string  'iso_abbreviation'
      t.string  'published_in'
      t.string  'iso_abbreviation'
      t.date    'completion_date'
      t.date    'revision_date'
      t.date    'publication_date'
      t.string  'publication_date_str'
      t.integer 'publication_year'
      t.integer 'publication_month'
      t.integer 'publication_day'
      t.string  'title'
      t.string  'pagination'
      t.string  'abstract'
      t.string  'country'
      t.string  'country_qcode'
      t.string  'language'
      t.string  'medline_ta'
      t.string  'nlm_unique_id'
      t.string  'issn_linking'
    end

    create_table 'pubmed.other_ids' do |t|
      t.string  'pmid'
      t.string  'id_type'
      t.string  'id_value'
    end

    create_table 'pubmed.authors' do |t|
      t.string  'pmid'
      t.string  'last_name'
      t.string  'first_name'
      t.string  'initials'
      t.string  'name'
      t.string  'affiliation'
    end

    create_table 'pubmed.chemicals' do |t|
      t.string  'pmid'
      t.string  'registry_number'
      t.string  'ui'
      t.string  'name'
    end

    create_table 'pubmed.types' do |t|
      t.string  'pmid'
      t.string  'ui'
      t.string  'name'
    end

    create_table 'pubmed.grants' do |t|
      t.string  'pmid'
      t.string  'grant_id'
      t.string  'acronym'
      t.string  'agency'
      t.string  'country'
      t.string  'country_qcode'
    end

    create_table 'pubmed.mesh_terms' do |t|
      t.string  'pmid'
      t.string  'ui'
      t.string  'name'
      t.boolean 'major_topic'
      t.string  'qualifier_name'
      t.string  'qualifier_ui'
      t.string  'qualifier_major_topic'
    end
  end

end
