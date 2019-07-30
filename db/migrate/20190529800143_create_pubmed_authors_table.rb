class CreatePubmedAuthorsTable < ActiveRecord::Migration

  def change

    create_table 'pubmed.authors' do |t|
      t.belongs_to 'pubmed.publication', index: true
      t.string   'pmid'
      t.string   'nct_id'
      t.string   'qcode'
      t.string   'orcid'
      t.boolean  'validated'
      t.string   'last_name'
      t.string   'first_name'
      t.string   'initials'
      t.string   'name'
      t.string   'downcase_name'
    end

    create_table 'pubmed.author_affiliations' do |t|
      t.belongs_to 'pubmed.author', index: true
      t.string   'pmid'
      t.string   'nct_id'
      t.string   'qcode'
      t.string   'isni'
      t.string   'grid'
      t.string   'name'
      t.string   'downcase_name'
    end

  end

end
