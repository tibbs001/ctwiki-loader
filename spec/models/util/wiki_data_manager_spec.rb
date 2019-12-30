require 'rails_helper'

describe Util::WikiDataManager do

  xit "should return multiple qcodes if there are multiple entities for one nct id" do
  end

  it "should correctly determine if a study exists/doesn't exist in wikidata" do

    stub_request(:post, "https://query.wikidata.org/sparql").
         with(
           body: {"query"=>"SELECT ?item WHERE { ?item wdt:P3098 'NCT03055247' . } "},
           headers: {
       	  'Accept'=>'application/sparql-results+json, application/sparql-results+xml, text/boolean, text/tab-separated-values;q=0.8, text/csv;q=0.2, */*;q=0.1',
       	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
       	  'Connection'=>'keep-alive',
       	  'Content-Type'=>'application/x-www-form-urlencoded',
       	  'Keep-Alive'=>'120',
       	  'User-Agent'=>'ctwiki-loader (https://github.com/tibbs001/ctwiki-loader) sheri.tibbs@duke.edu'
           }).
         to_return(status: 200, body: [RDF::Query::Solution.new({:item=>RDF::URI.new('http://www.wikidata.org/entity/Q60501336')})], headers: {})



       stub_request(:post, "https://query.wikidata.org/sparql").
         with(
           body: {"query"=>"SELECT ?item WHERE { ?item wdt:P3098 'non_existent_nct_id' . } "},
           headers: {
       	  'Accept'=>'application/sparql-results+json, application/sparql-results+xml, text/boolean, text/tab-separated-values;q=0.8, text/csv;q=0.2, */*;q=0.1',
       	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
       	  'Connection'=>'keep-alive',
       	  'Content-Type'=>'application/x-www-form-urlencoded',
       	  'Keep-Alive'=>'120',
       	  'User-Agent'=>'ctwiki-loader (https://github.com/tibbs001/ctwiki-loader) sheri.tibbs@duke.edu'
           }).
         to_return(status: 200, body: [], headers: {})


    wikidata_study='NCT03055247'
    mgr=Util::WikiDataManager.new
    expect(mgr.study_already_loaded?(wikidata_study)).to be(true)
    non_wikidata_study='non_existent_nct_id'
    expect(mgr.study_already_loaded?(non_wikidata_study)).to be(false)
  end

  it "should not return a person-type entity" do

       stub_request(:get, "https://www.wikidata.org/w/api.php?action=wbsearchentities&format=json&language=en&search=patient").
         with(
           headers: {
       	  'Accept'=>'*/*',
       	  'Accept-Encoding'=>'gzip, deflate',
       	  'Host'=>'www.wikidata.org',
       	  'User-Agent'=>'rest-client/2.0.2 (darwin18.7.0 x86_64) ruby/2.4.5p335'
           }).

           to_return(status: 200, body: "{\"searchinfo\":{\"search\":\"patient\"},\"search\":[{\"repository\":\"\",\"id\":\"Q181600\",\"concepturi\":\"http://www.wikidata.org/entity/Q181600\",\"title\":\"Q181600\",\"pageid\":180760,\"url\":\"//www.wikidata.org/wiki/Q181600\",\"label\":\"patient\",\"description\":\"person who takes a medical treatment or is subject of a case study\",\"match\":{\"type\":\"label\",\"language\":\"en\",\"text\":\"patient\"}},{\"repository\":\"\",\"id\":\"Q170212\",\"concepturi\":\"http://www.wikidata.org/entity/Q170212\",\"title\":\"Q170212\",\"pageid\":170556,\"url\":\"//www.wikidata.org/wiki/Q170212\",\"label\":\"patient\",\"description\":\"grammar: participant of a situation upon whom an action is carried out or the thematic relation such a participant has with an action. Sometimes, \\\"theme\\\" and \\\"patient\\\" are used to mean the same thing\",\"match\":{\"type\":\"label\",\"language\":\"en\",\"text\":\"patient\"}},{\"repository\":\"\",\"id\":\"Q17017504\",\"concepturi\":\"http://www.wikidata.org/entity/Q17017504\",\"title\":\"Q17017504\",\"pageid\":18622695,\"url\":\"//www.wikidata.org/wiki/Q17017504\",\"label\":\"Patient UK\",\"description\":\"website providing information on health, lifestyle, disease and other medical related topics\",\"match\":{\"type\":\"label\",\"language\":\"en\",\"text\":\"Patient UK\"}},{\"repository\":\"\",\"id\":\"Q36919912\",\"concepturi\":\"http://www.wikidata.org/entity/Q36919912\",\"title\":\"Q36919912\",\"pageid\":38300438,\"url\":\"//www.wikidata.org/wiki/Q36919912\",\"label\":\"Patient\",\"description\":\"family name\",\"match\":{\"type\":\"label\",\"language\":\"en\",\"text\":\"Patient\"}},{\"repository\":\"\",\"id\":\"Q7144957\",\"concepturi\":\"http://www.wikidata.org/entity/Q7144957\",\"title\":\"Q7144957\",\"pageid\":7042994,\"url\":\"//www.wikidata.org/wiki/Q7144957\",\"label\":\"Patient\",\"description\":\"album by Bluebottle Kiss\",\"match\":{\"type\":\"label\",\"language\":\"en\",\"text\":\"Patient\"}},{\"repository\":\"\",\"id\":\"Q7144958\",\"concepturi\":\"http://www.wikidata.org/entity/Q7144958\",\"title\":\"Q7144958\",\"pageid\":7042995,\"url\":\"//www.wikidata.org/wiki/Q7144958\",\"label\":\"Patient\",\"description\":\"memoir by musician Ben Watt\",\"match\":{\"type\":\"label\",\"language\":\"en\",\"text\":\"Patient\"}},{\"repository\":\"\",\"id\":\"Q15760736\",\"concepturi\":\"http://www.wikidata.org/entity/Q15760736\",\"title\":\"Q15760736\",\"pageid\":17394034,\"url\":\"//www.wikidata.org/wiki/Q15760736\",\"label\":\"Patient Education and Counseling\",\"description\":\"journal\",\"match\":{\"type\":\"label\",\"language\":\"en\",\"text\":\"Patient Education and Counseling\"}}],\"search-continue\":7,\"success\":1}", headers: {})
    possible_descriptions = Lookup::Intervention.possible_descriptions
    impossible_descriptions = Lookup::Intervention.impossible_descriptions
    search_string = 'patient'
    result = described_class.new.find_qcode(search_string, possible_descriptions, impossible_descriptions)
    expect(result).to eq(nil)
  end

  it "should find the right qcode for ribavirin with a suffix" do

    stub_request(:get, "https://www.wikidata.org/w/api.php?action=wbsearchentities&format=json&language=en&search=ribavirin").
         with(
           headers: {
       	  'Accept'=>'*/*',
       	  'Accept-Encoding'=>'gzip, deflate',
       	  'Host'=>'www.wikidata.org',
       	  'User-Agent'=>'rest-client/2.0.2 (darwin18.7.0 x86_64) ruby/2.4.5p335'
           }).
         to_return(status: 200, body: "{'searchinfo':{'search':'ribavirin'},'search':[{'repository':'','id':'Q421862','concepturi':'http://www.wikidata.org/entity/Q421862','title':'Q421862','pageid':398543,'url':'//www.wikidata.org/wiki/Q421862','label':'ribavirin','description':'chemical compound','match':{'type':'label','language':'en','text':'ribavirin'}},{'repository':'','id':'Q21761870','concepturi':'http://www.wikidata.org/entity/Q21761870','title':'Q21761870','pageid':23800209,'url':'//www.wikidata.org/wiki/Q21761870','label':'Ribavirin','description':'NIOSH analytical method','match':{'type':'label','language':'en','text':'Ribavirin'}},{'repository':'','id':'Q29006440','concepturi':'http://www.wikidata.org/entity/Q29006440','title':'Q29006440','pageid':30666268,'url':'//www.wikidata.org/wiki/Q29006440','label':'Ribavirin Mylan','description':'pharmaceutical product','match':{'type':'label','language':'en','text':'Ribavirin Mylan'}},{'repository':'','id':'Q29006439','concepturi':'http://www.wikidata.org/entity/Q29006439','title':'Q29006439','pageid':30666267,'url':'//www.wikidata.org/wiki/Q29006439','label':'Ribavirin Biopartners','description':'pharmaceutical product','match':{'type':'label','language':'en','text':'Ribavirin Biopartners'}},{'repository':'','id':'Q29006441','concepturi':'http://www.wikidata.org/entity/Q29006441','title':'Q29006441','pageid':30666269,'url':'//www.wikidata.org/wiki/Q29006441','label':'Ribavirin Teva','description':'pharmaceutical product','match':{'type':'label','language':'en','text':'Ribavirin Teva'}},{'repository':'','id':'Q29006443','concepturi':'http://www.wikidata.org/entity/Q29006443','title':'Q29006443','pageid':30666271,'url':'//www.wikidata.org/wiki/Q29006443','label':'Ribavirin Teva Pharma B.v.','description':'pharmaceutical product','match':{'type':'label','language':'en','text':'Ribavirin Teva Pharma B.v.'}},{'repository':'','id':'Q27260032','concepturi':'http://www.wikidata.org/entity/Q27260032','title':'Q27260032','pageid':29072987,'url':'//www.wikidata.org/wiki/Q27260032','label':'ribavirin elaidate','description':'chemical compound','match':{'type':'label','language':'en','text':'ribavirin elaidate'}}],'search-continue':7,'success':1}", headers: {})

    possible_descriptions = Lookup::Intervention.possible_descriptions
    impossible_descriptions = Lookup::Intervention.impossible_descriptions
    search_string = 'ribavirin'
    result = described_class.new.find_qcode(search_string, possible_descriptions, impossible_descriptions)
    expect(result[:qcode]).to eq('Q421862')
    expect(result[:wiki_description]).to eq('chemical compound')

  end

  it "should produce expected qcode for metreleptin" do
    search_string='metreleptin'
    possible_descriptions = Lookup::Intervention.possible_descriptions
    impossible_descriptions = Lookup::Intervention.impossible_descriptions
    stub_request(:get, "https://www.wikidata.org/w/api.php?action=wbsearchentities&format=json&language=en&search=metreleptin").
         with(
           headers: {
       	  'Accept'=>'*/*',
       	  'Accept-Encoding'=>'gzip, deflate',
       	  'Host'=>'www.wikidata.org',
       	  'User-Agent'=>'rest-client/2.0.2 (darwin18.7.0 x86_64) ruby/2.4.5p335'
           }).
         to_return(status: 200, body: "
                   {'searchinfo':{'search':'metreleptin'},'search':[{'repository':'','id':'Q17143468','concepturi':'http://www.wikidata.org/entity/Q17143468','title':'Q17143468','pageid':18737070,'url':'//www.wikidata.org/wiki/Q17143468','label':'Metreleptin','description':'pharmaceutical drug','match':{'type':'label','language':'en','text':'Metreleptin'}},{'repository':'','id':'Q34348966','concepturi':'http://www.wikidata.org/entity/Q34348966','title':'Q34348966','pageid':35787883,'url':'//www.wikidata.org/wiki/Q34348966','label':'Metreleptin: first global approval.','description':'scientific article','match':{'type':'label','language':'en','text':'Metreleptin: first global approval.'}},{'repository':'','id':'Q37275992','concepturi':'http://www.wikidata.org/entity/Q37275992','title':'Q37275992','pageid':38653050,'url':'//www.wikidata.org/wiki/Q37275992','label':'Metreleptin improves blood glucose in patients with insulin receptor mutations.','description':'scientific article published on 22 August 2013','match':{'type':'label','language':'en','text':'Metreleptin improves blood glucose in patients with insulin receptor mutations.'}},{'repository':'','id':'Q37062692','concepturi':'http://www.wikidata.org/entity/Q37062692','title':'Q37062692','pageid':38442231,'url':'//www.wikidata.org/wiki/Q37062692','label':'Metreleptin for injection to treat the complications of leptin deficiency in patients with congenital or acquired generalized lipodystrophy','description':'scientific article published on 14 October 2015','match':{'type':'label','language':'en','text':'Metreleptin for injection to treat the complications of leptin deficiency in patients with congenital or acquired generalized lipodystrophy'}},{'repository':'','id':'Q38524414','concepturi':'http://www.wikidata.org/entity/Q38524414','title':'Q38524414','pageid':39888463,'url':'//www.wikidata.org/wiki/Q38524414','label':'Metreleptin and generalized lipodystrophy and evolving therapeutic perspectives.','description':'scientific article published on July 2015','match':{'type':'label','language':'en','text':'Metreleptin and generalized lipodystrophy and evolving therapeutic perspectives.'}},{'repository':'','id':'Q37567810','concepturi':'http://www.wikidata.org/entity/Q37567810','title':'Q37567810','pageid':38941739,'url':'//www.wikidata.org/wiki/Q37567810','label':'Metreleptin Treatment in Three Patients with Generalized Lipodystrophy.','description':'scientific article published on January 2016','match':{'type':'label','language':'en','text':'Metreleptin Treatment in Three Patients with Generalized Lipodystrophy.'}},{'repository':'','id':'Q45921186','concepturi':'http://www.wikidata.org/entity/Q45921186','title':'Q45921186','pageid':47074262,'url':'//www.wikidata.org/wiki/Q45921186','label':'Metreleptin therapy in LMNA-linked lipodystrophies.','description':'scientific article published on 11 November 2015','match':{'type':'label','language':'en','text':'Metreleptin therapy in LMNA-linked lipodystrophies.'}}],'search-continue':7,'success':1}", headers: {})


    result = described_class.new.find_qcode(search_string, possible_descriptions, impossible_descriptions)
    expect(result[:qcode]).to eq('Q17143468')
    expect(result[:name]).to eq(search_string)
    expect(result[:wiki_description]).to eq('pharmaceutical drug')
  end

  it "should not return a scientific article" do
    search_string = 'blood sugar testing'
    possible_descriptions = Lookup::Intervention.possible_descriptions
    impossible_descriptions = Lookup::Intervention.impossible_descriptions
    stub_request(:get, "https://www.wikidata.org/w/api.php?action=wbsearchentities&format=json&language=en&search=blood%20sugar%20testing").
         with(
           headers: {
       	  'Accept'=>'*/*',
       	  'Accept-Encoding'=>'gzip, deflate',
       	  'Host'=>'www.wikidata.org',
       	  'User-Agent'=>'rest-client/2.0.2 (darwin18.7.0 x86_64) ruby/2.4.5p335'
           }).
         to_return(status: 200, body: "{'searchinfo':{'search':'blood sugar testing'},'search':[{'repository':'','id':'Q53618777','concepturi':'http://www.wikidata.org/entity/Q53618777','title':'Q53618777','pageid':54124420,'url':'//www.wikidata.org/wiki/Q53618777','label':'Blood sugar testing.','description':'scientific article','match':{'type':'label','language':'en','text':'Blood sugar testing.'}}],'success':1}", headers: {})

    result = described_class.new.find_qcode(search_string, possible_descriptions, impossible_descriptions)
    expect(result).to be(nil)
  end

end
