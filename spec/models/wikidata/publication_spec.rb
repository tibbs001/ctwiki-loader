require 'rails_helper'

describe Wikidata::Publication do
  it "saves a pub xml to the pub_xml_record" do
    pmid='7906420'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{pmid}.xml"))
    xml_record=Util::Client.new.create_xml_record({:pmid => pmid, xml: xml})
    expect(xml_record.pmid).to eq(pmid)
    pub=Wikidata::Publication.new({xml: xml, pmid: pmid}).create
    expect(pub.pmid).to eq(pmid)
    expect(pub.issn).to eq('0033-2917')
    expect(pub.volume).to eq('Suppl 24')
    #expect(pub.iso_abbreviation).to eq('Psychol Med')
    expect(pub.published_in).to eq('Psychological medicine')
    expect(pub.title).to eq('The premenstrual syndrome--a reappraisal of the concept and the evidence.')
    expect(pub.pagination).to eq('1-47')
  end
end
