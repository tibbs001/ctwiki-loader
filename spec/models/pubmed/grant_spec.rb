require 'rails_helper'

describe Pubmed::Grant do

  it "creates authors from the xml" do
    pmid='16002928'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{pmid}.xml"))
    lm = Util::LookupManager.new
    grants=Pubmed::Grant.create_all_from({xml: xml, pmid: pmid, lookup_mgr: lm})
    expect(grants.size).to eq(1)
    grant=grants.first
    expect(grant.grant_id).to eq('K23 HL 04411')
    expect(grant.acronym).to  eq('HL')
    expect(grant.agency).to   eq('NHLBI NIH HHS')
#    expect(grant.country).to  eq('United States')
#    expect(grant.country_qcode).to  eq('Q30')
  end

end

