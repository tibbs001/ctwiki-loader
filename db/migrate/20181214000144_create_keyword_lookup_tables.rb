class CreateKeywordLookupTables < ActiveRecord::Migration[7.0]

  def change

    create_table 'lookup.keywords' do |t|
      t.string  'qcode'
      t.string  'preferred_name'
      t.string  'name'
      t.string  'types'
      t.string  'downcase_name'
      t.string  'lookup'
      t.string  'wiki_description'
      t.string  'looks_suspicious'
    end

  end

end
