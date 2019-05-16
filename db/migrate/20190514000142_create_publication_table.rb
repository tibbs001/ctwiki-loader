class CreatePublicationTable < ActiveRecord::Migration

  def change

    create_table "wikidata.pub_xml_records", force: :cascade do |t|
      t.string   "pmid"
      t.xml      "content"
      t.datetime "created_pub_at"
      t.timestamps null: false
    end

    create_table 'wikidata.publications' do |t|
      t.string  'pmid'
      t.string  'issn'
      t.string  'volume'
      t.string  'issue'
      t.string  'published_in'
      t.string  'publication_date'
      t.string  'title'
      t.string  'pagination'
      t.string  'abstract'
    end

  end

end
