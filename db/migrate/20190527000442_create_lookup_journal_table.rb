class CreateLookupJournalTable < ActiveRecord::Migration[7.0]

  def change

    create_table 'lookup.journals' do |t|
      t.string  'qcode'
      t.string  'types'
      t.string  'name'
      t.string  'downcase_name'
      t.string  'wiki_description'
      t.string  'looks_suspicious'
    end
  end

end
