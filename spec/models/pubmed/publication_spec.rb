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

    expect(pub.authors.size).to eq(4)
    expect(pub.authors.select{|a| a.last_name == 'White'}.first.first_name).to eq('Alexander C')
    expect(pub.authors.select{|a| a.last_name == 'White'}.first.affiliation).to eq("Pulmonary, Critical Care and Sleep Division, New England Medical Center, NEMC #369, 750 Washington St, Boston, MA 02111, USA. Awhite1@Tufts-NEMC.org")
    expect(pub.authors.select{|a| a.last_name == 'Miller'}.first.initials).to eq('KB')

    expect(pub.types.size).to eq(3)
    expect(pub.types.select{|a| a.ui == 'D016428'}.first.name).to eq('Journal Article')
    expect(pub.types.select{|a| a.ui == 'D052061'}.first.name).to eq('Research Support, N.I.H., Extramural')

    expect(pub.grants.size).to eq(1)
    grant=pub.grants.first
    expect(grant.grant_id).to eq('K23 HL 04411')
    expect(grant.acronym).to  eq('HL')
    expect(grant.agency).to   eq('NHLBI NIH HHS')
    expect(grant.country).to  eq('United States')
  end

end
