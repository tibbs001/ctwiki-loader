require 'rails_helper'

describe Util::StudyPrepper do

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
         to_return(status: 200, body: [], headers: {})

    # the test AACT db should have the 3 expected sample studies
    # if not, check method in database_cleaner.rb
    expect(Ctgov::Study.count).to eq(3)
    expect(Util::StudyPrepper.source_model_name.new({}).nct_id).to be(nil)
  end

  it "should retrieve source data from the correct tables" do
    expect(Ctgov::Study.count).to eq(3)
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
         to_return(status: 200, body: [], headers: {})

    lm = Util::LookupManager.new
    pmid='7906420'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{pmid}.xml"))
    pub=Pubmed::Publication.new({xml: xml, pmid: pmid, lookup_mgr: lm}).create

    Lookup::Country.destroy_all
    Lookup::Intervention.destroy_all
    Lookup::Keyword.destroy_all
    Lookup::Sponsor.destroy_all
    Lookup::Sponsor.new({:qcode=>'Q3519875',
                         :name=>'National Institute of Allergy and Infectious Diseases (NIAID)',
                         :downcase_name=>'national institute of allergy and infectious diseases (niaid)'}).save!
    Lookup::Sponsor.new({:qcode=>'Q664846',
                         :name=>'National Cancer Institute (NCI)',
                         :downcase_name=>'national cancer institute (nci)'}).save!
    Lookup::Sponsor.new({:qcode=>'Q1967405',
                         :name=>'National Institute of Mental Health (NIMH)',
                         :downcase_name=>'national institute of mental health (nimh)'}).save!
    Lookup::Country.new({:qcode=>'Q30',
                         :name=>'United States',
                         :downcase_name=>'united states'}).save!
    Lookup::Intervention.new({:qcode=>'Q56953162',
                         :name=>'Anti-Retroviral Agents',
                         :downcase_name=>'anti-retroviral agents'}).save!
    Lookup::Keyword.new({:qcode=>'Q34731367',
                         :name=>'Viral Suppression',
                         :downcase_name=>'viral suppression'}).save!
    Lookup::Keyword.new({:qcode=>'Q15787',
                         :name=>'Immunodeficiency',
                         :downcase_name=>'immunodeficiency'}).save!

    #Lookup::Organization.populate_predefined_qcode

    # data source method should return a Study-type that answers to nct_id.  Would raise an error if no nct_id

    Util::StudyPrepper.run
    quickstatement_file_name="public/0_study_quickstatements.txt"
    expect(File.exists? quickstatement_file_name).to eq(true)
    content = ''
    f = File.open(quickstatement_file_name, "r")
    f.each_line do |line|
      content += line
    end
    # to do: account for different delimiters - the content could be a single long line if delimiters are bars (|)
    # or content could be series of quickstatement command separated by new lines.  Should test both ways
    # For now, just verify the file bascially contains expected content - no matter which delimiter is being used

    expect(content).to include("NCT00001899")
    expect(content).to include("NCT00011414")
    expect(content).to include("NCT00055575")
    expect(content).to include("en:\"Immunologic and Virologic Characterization of HIV-Infected Patients After Cessation of Highly Active Antiretroviral Therapy (HAART)\"")
    expect(content.scan(/(?=CREATE)/).count).to eq(3)
  end

end
