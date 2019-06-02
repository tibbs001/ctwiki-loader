require 'rails_helper'

describe Util::PubPrepper do

  it "should retrieve source data from the correct tables" do
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

    pmid='24157819'
    lm = Util::LookupManager.new
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{pmid}.xml"))
    pub=Pubmed::Publication.new({xml: xml, pmid: pmid, lookup_mgr: lm}).create
    Lookup::Author.destroy_all
    Lookup::Author.new({:qcode=>'Q57261725',
                         :name=>'0000-0003-3306-5364',
                         :downcase_name=>'0000-0003-3306-5364'}).save!
    expect(Util::PubPrepper.source_model_name.new({}).pmid).to be(nil)
    quickstatement_file_name="public/0_publication_quickstatements.txt"
    File.delete(quickstatement_file_name) if File.exists? quickstatement_file_name
    expect(File.exists? quickstatement_file_name).to eq(false)

    Util::PubPrepper.new.run({:batch_of_ids=>['24157819']})
    expect(File.exists? quickstatement_file_name).to eq(true)
    content = ''
    f = File.open(quickstatement_file_name, "r")
    f.each_line do |line|
      content += line
    end
    # todo:  if we set the quickstatement delimiters in the test, we can define more accurate tests
    # such as:  expect(content).to include("LAST\tP50\tQ57261725")
    # or expect(content).to include("LAST\tP2093\tSheryl Fenwick")
    expect(content).to include("P50")        # property for linking to an author entity
    expect(content).to include("Q57261725")  # the qcode for author with orcid (name) 0000-0003-3306-5364
    expect(content).to include("P2093")      # author name property
    expect(content).to include("Sheryl Fenwick")   # one of the author names
    expect(content).to include("P577")       # publication date property
    expect(content).to include("+2013-10-23T00:00:00Z/11")  # publication date
  end

end
