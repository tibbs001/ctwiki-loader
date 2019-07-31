class CreateChemicalLookupTable < ActiveRecord::Migration
  def change

    create_table 'lookup.chemicals' do |t|
      t.string  'qcode'
      t.string  'types'
      t.string  'preferred_name'
      t.string  'ui'
      t.string  'name'
      t.string  'downcase_name'
      t.string  'lookup'
      t.string  'wiki_description'
      t.string  'looks_suspicious'
    end

  end
end
