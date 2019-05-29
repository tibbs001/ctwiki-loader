require 'rails_helper'

describe Pubmed::Author do

  it "creates authors from the xml" do
    pmid='28481359'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{pmid}.xml"))
    lm = Util::LookupManager.new
    authors=Pubmed::Author.create_all_from({xml: xml, pmid: pmid, lookup_mgr: lm})

    expect(authors.size).to eq(100)
    a= authors.select{|a| a.last_name =='Zehir'}.first
    expect(a.first_name).to eq('Ahmet')
    expect(a.initials).to eq('A')
    expect(a.name).to eq('Ahmet Zehir')
    expect(a.downcase_name).to eq('ahmet zehir')
    expect(a.orcid).to eq('0000-0001-5406-4104')
  end

end

