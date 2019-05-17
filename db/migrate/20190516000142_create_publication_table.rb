class CreatePublicationTable < ActiveRecord::Migration

  def change

    create_table 'pubmed.publications' do |t|
      t.string  'pmid'
      t.string  'issn'
      t.string  'volume'
      t.string  'issue'
      t.string  'iso_abbreviation'
      t.string  'published_in'
      t.string  'publication_date'
      t.string  'title'
      t.string  'pagination'
      t.string  'abstract'
    end

  end

end
