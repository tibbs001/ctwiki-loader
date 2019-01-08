class CreateLookupTables < ActiveRecord::Migration
  def change

    create_table 'lookup.countries' do |t|
      t.string  'qcode'
      t.string  'name'
      t.string  'downcase_name'
      t.string  'iso2'
      t.string  'osm_relid'
      t.string  'wiki_description'
      t.string  'looks_suspicious'
    end

    create_table 'lookup.conditions' do |t|
      t.string  'qcode'
      t.string  'preferred_name'
      t.string  'name'
      t.string  'downcase_name'
      t.string  'lookup'
      t.string  'wiki_description'
      t.string  'looks_suspicious'
    end

    create_table 'lookup.interventions' do |t|
      t.string  'qcode'
      t.string  'preferred_name'
      t.string  'name'
      t.string  'downcase_name'
      t.string  'wiki_description'
      t.string  'looks_suspicious'
    end

    create_table 'lookup.organizations' do |t|
      t.string  'preferred_name'
      t.string  'qcode'
      t.string  'name'
      t.string  'downcase_name'
      t.string  'wiki_description'
      t.string  'looks_suspicious'
    end

    create_table 'lookup.sponsors' do |t|
      t.string  'preferred_name'
      t.string  'qcode'
      t.string  'name'
      t.string  'downcase_name'
      t.string  'wiki_description'
      t.string  'looks_suspicious'
    end

    #add_index 'lookup.interventions', :qcode
    #add_index 'lookup.interventions', :name
    #add_index 'lookup.intervention',  :downcase_name

    #add_index 'lookup.sponsors', :qcode
    #add_index 'lookup.sponsors', :name
    #add_index 'lookup.sponsors', :downcase_name

  end
end
