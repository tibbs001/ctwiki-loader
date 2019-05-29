require 'rails_helper'

describe Pubmed::Publication do

  it "saves a pub xml to the pub_xml_record" do
    pmid='28481359'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{pmid}.xml"))
    pub=Pubmed::Publication.new({xml: xml, pmid: pmid}).create
    expect(pub.authors.size).to eq(6)
    a= pub.authors.select{|a| a.last_name =='Zehir'}.first
    expect(a.first_nme).to eq('Ahmet')
    expect(a.initials).to eq('A')
    expect(a.name).to eq('Ahmet Zehir')
    expect(a.downcase_name).to eq('ahmet zehir')
    expect(a.orcid).to eq(' http://orcid.org/0000-0001-5406-4104')
  end
end

