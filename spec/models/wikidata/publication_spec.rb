require 'rails_helper'

describe Wikidata::PublicationSpec do
  it "saves a pub xml to the pub_xml_record" do
    pmid='7906420'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{pmid}.xml"))
    pub_xml_record=Util::Client.new.create_pub_xml_record({:pmid => pmid, xml: xml})
    expect(pub_xml_record.pmid).to eq(pmid)
  end
end
