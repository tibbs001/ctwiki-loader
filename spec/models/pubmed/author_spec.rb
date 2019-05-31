require 'rails_helper'

describe Pubmed::Author do

  it "creates authors from the xml" do
           stub_request(:post, "https://query.wikidata.org/sparql").
         with(
           body: {"query"=>"SELECT ?item ?nct_id WHERE { ?item p:P31/ps:P31/wdt:P279* wd:Q30612.  ?item wdt:P3098 ?nct_id . }"},
           headers: {
       	  'Accept'=>'application/sparql-results+json, application/sparql-results+xml, text/boolean, text/tab-separated-values;q=0.8, text/csv;q=0.2, */*;q=0.1',
       	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
       	  'Connection'=>'keep-alive',
       	  'Content-Type'=>'application/x-www-form-urlencoded',
       	  'Keep-Alive'=>'120',
       	  'User-Agent'=>'Ruby'
           }).
         to_return(status: 200, body: "", headers: {})
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

