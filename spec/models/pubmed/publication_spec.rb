require 'rails_helper'

describe Pubmed::Publication do
  it "saves a pub xml to the pub_xml_record" do
    pmid='7906420'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{pmid}.xml"))
    pub=Pubmed::Publication.new({xml: xml, pmid: pmid}).create
    expect(pub.pmid).to eq(pmid)
    expect(pub.issn).to eq('0033-2917')
    expect(pub.volume).to eq('Suppl 24')
    #expect(pub.iso_abbreviation).to eq('Psychol Med')
    expect(pub.published_in).to eq('Psychological medicine')
    expect(pub.title).to eq('The premenstrual syndrome--a reappraisal of the concept and the evidence.')
    expect(pub.pagination).to eq('1-47')
  end

  it "saves a 2nd pub xml to the pub_xml_record" do
    pmid='16002928'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{pmid}.xml"))
    pub=Pubmed::Publication.new({xml: xml, pmid: pmid}).create
    expect(pub.pmid).to eq(pmid)
    expect(pub.issn).to eq('0012-3692')
    expect(pub.volume).to eq('128')
    #expect(pub.iso_abbreviation).to eq('Psychol Med')
    expect(pub.published_in).to eq('Chest')
    expect(pub.title).to eq('Impaired respiratory and skeletal muscle strength in patients prior to hematopoietic stem-cell transplantation.')
    expect(pub.pagination).to eq('145-52')
    expect(pub.other_ids.size).to eq(3)
    expect(pub.other_ids.select{|id| id.id_type == 'pii'}.first.id_value).to eq('S0012-3692(15)37939-3')
    expect(pub.other_ids.select{|id| id.id_type == 'doi'}.first.id_value).to eq('10.1378/chest.128.1.145')
  end

end
