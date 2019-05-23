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
      t.string  'title'
      t.string  'pagination'
      t.string  'abstract'
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
    end

    create_table 'pubmed.mesh_terms' do |t|
      t.string  'pmid'
      t.string  'ui'
      t.string  'mesh_term'
      t.boolean 'major_topic'
    end
  end

end
