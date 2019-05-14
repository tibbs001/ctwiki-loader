class CreatePublicationLookupTables < ActiveRecord::Migration

  def change

    create_table 'lookup.publications' do |t|
      t.string  'qcode'
      t.string  'min_or_max'
      t.string  'preferred_name'
      t.string  'name'
      t.string  'downcase_name'
      t.string  'pmid'
      t.string  'lookup'
      t.string  'wiki_description'
      t.string  'looks_suspicious'
    end

  end

end
