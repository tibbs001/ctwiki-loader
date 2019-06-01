class CreateAuthorLookupTable < ActiveRecord::Migration
  def change

    create_table 'lookup.authors' do |t|
      t.string  'qcode'
      t.string  'types'
      t.string  'name'
      t.string  'downcase_name'
      t.string  'wiki_description'
      t.string  'looks_suspicious'
    end

    add_index 'lookup.authors', :qcode
    add_index 'lookup.authors', :name
    add_index 'lookup.authors', :downcase_name

  end
end
