require 'rails_helper'

describe Pubmed::Publication do

  it "creates a publication with correct pub date when only day & month" do
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

    pmid='21522216'
    lm = Util::LookupManager.new
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{pmid}.xml"))
    pub=Pubmed::Publication.new({xml: xml, pmid: pmid, lookup_mgr: lm}).create
    expect(pub.pmid).to eq(pmid)
    expect(pub.publication_date_str).to eq('2006 May')
    expect(pub.publication_year).to eq(2006)
    # because only publication year and month provided, the quickstatement should code the date with a /10 suffix.
    expect(pub.pub_date_quickstatement("")).to eq("+2006-05-01T00:00:00Z/10")
  end

  it "creates a publication with correct attribute values" do
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

    pmid='24157819'
    lm = Util::LookupManager.new
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{pmid}.xml"))
    pub=Pubmed::Publication.new({xml: xml, pmid: pmid, lookup_mgr: lm}).create
    expect(pub.pmid).to eq('24157819')
    expect(pub.publication_year).to eq(2013)
    expect(pub.issue).to eq('10')
    # because pubdate has a 'day', the quickstatement should have /11 suffix
    expect(pub.pub_date_quickstatement("")).to eq("+2013-10-23T00:00:00Z/11")
    expect(pub.name).to eq("BMJ open")
  end

  it "saves a pub xml to the pub_xml_record" do
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

    pmid='7906420'
    lm = Util::LookupManager.new
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{pmid}.xml"))
    pub=Pubmed::Publication.new({xml: xml, pmid: pmid, lookup_mgr: lm}).create
    expect(pub.pmid).to eq(pmid)
    expect(pub.issn).to eq('0033-2917')
    expect(pub.volume).to eq('Suppl 24')
    expect(pub.country).to eq('England')
    #expect(pub.iso_abbreviation).to eq('Psychol Med')
    expect(pub.published_in).to eq('Psychological medicine')
    expect(pub.title).to eq('The premenstrual syndrome--a reappraisal of the concept and the evidence.')
    expect(pub.pagination).to eq('1-47')
    expect(pub.publication_year).to eq(1993)

    expect(pub.chemicals.size).to eq(2)
    expect(pub.chemicals.select{|c| c.ui == 'D012739'}.first.name).to eq('Gonadal Steroid Hormones')
  end

  it "saves a 2nd pub xml to the pub_xml_record" do
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

    pmid='16002928'
    lm = Util::LookupManager.new
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{pmid}.xml"))
    pub=Pubmed::Publication.new({xml: xml, pmid: pmid, lookup_mgr: lm}).create
    expect(pub.pmid).to eq(pmid)
    expect(pub.issn).to eq('0012-3692')
    expect(pub.volume).to eq('128')
    #expect(pub.iso_abbreviation).to eq('Psychol Med')
    expect(pub.published_in).to eq('Chest')
    expect(pub.title).to eq('Impaired respiratory and skeletal muscle strength in patients prior to hematopoietic stem-cell transplantation.')
    expect(pub.publication_year).to eq(2005)
    expect(pub.publication_month).to eq(7)
    expect(pub.publication_date).to eq(Date.parse('01-07-2005')) # use first of month if no day provided
    expect(pub.publication_date_str).to eq('2005 Jul')
    expect(pub.pagination).to eq('145-52')
    expect(pub.nlm_unique_id).to eq('0231335')

    expect(pub.other_ids.size).to eq(3)
    expect(pub.other_ids.select{|id| id.id_type == 'pii'}.first.id_value).to eq('S0012-3692(15)37939-3')
    expect(pub.other_ids.select{|id| id.id_type == 'doi'}.first.id_value).to eq('10.1378/chest.128.1.145')

    expect(pub.authors.size).to eq(4)
    expect(pub.authors.select{|a| a.last_name == 'White'}.first.first_name).to eq('Alexander C')
    #expect(pub.authors.select{|a| a.last_name == 'White'}.first.affiliation).to eq("Pulmonary, Critical Care and Sleep Division, New England Medical Center, NEMC #369, 750 Washington St, Boston, MA 02111, USA. Awhite1@Tufts-NEMC.org")
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
    #expect(grant.country_qcode).to  eq('Q30')

    expect(pub.mesh_terms.size).to eq(13)
    expect(pub.mesh_terms.select{|a| a.ui == 'D000328'}.first.name).to eq('Adult')
    expect(pub.mesh_terms.select{|a| a.ui == 'D000328'}.first.major_topic).to eq(false)
    expect(pub.mesh_terms.select{|a| a.ui == 'D017079'}.first.name).to eq('Exercise Tolerance')
    expect(pub.mesh_terms.select{|a| a.ui == 'D017079'}.first.major_topic).to eq(true)
    term=pub.mesh_terms.select{|a| a.ui == 'D018908'}.first
    expect(term.name).to eq('Muscle Weakness')
    expect(term.qualifier_name).to eq('diagnosis')
    expect(term.qualifier_ui).to eq('Q000175')
    expect(term.qualifier_major_topic).to eq('t')
    expect(term.major_topic).to eq(false)
  end

end
