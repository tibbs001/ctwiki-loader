require 'rails_helper'

describe Lookup::Intervention do
  it "should find the right qcode for ribavirin with a suffix" do

    stub_request(:get, "https://www.wikidata.org/w/api.php?action=wbsearchentities&format=json&language=en&search=ribavirin").
         with(
           headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip, deflate',
          'Host'=>'www.wikidata.org',
          'User-Agent'=>'rest-client/2.0.2 (darwin16.7.0 x86_64) ruby/2.4.0p0'
           }).
         to_return(status: 200, body: "{'searchinfo':{'search':'ribavirin'},'search':[{'repository':'','id':'Q421862','concepturi':'http://www.wikidata.org/entity/Q421862','title':'Q421862','pageid':398543,'url':'//www.wikidata.org/wiki/Q421862','label':'ribavirin','description':'chemical compound','match':{'type':'label','language':'en','text':'ribavirin'}},{'repository':'','id':'Q21761870','concepturi':'http://www.wikidata.org/entity/Q21761870','title':'Q21761870','pageid':23800209,'url':'//www.wikidata.org/wiki/Q21761870','label':'Ribavirin','description':'NIOSH analytical method','match':{'type':'label','language':'en','text':'Ribavirin'}},{'repository':'','id':'Q29006440','concepturi':'http://www.wikidata.org/entity/Q29006440','title':'Q29006440','pageid':30666268,'url':'//www.wikidata.org/wiki/Q29006440','label':'Ribavirin Mylan','description':'pharmaceutical product','match':{'type':'label','language':'en','text':'Ribavirin Mylan'}},{'repository':'','id':'Q29006439','concepturi':'http://www.wikidata.org/entity/Q29006439','title':'Q29006439','pageid':30666267,'url':'//www.wikidata.org/wiki/Q29006439','label':'Ribavirin Biopartners','description':'pharmaceutical product','match':{'type':'label','language':'en','text':'Ribavirin Biopartners'}},{'repository':'','id':'Q29006441','concepturi':'http://www.wikidata.org/entity/Q29006441','title':'Q29006441','pageid':30666269,'url':'//www.wikidata.org/wiki/Q29006441','label':'Ribavirin Teva','description':'pharmaceutical product','match':{'type':'label','language':'en','text':'Ribavirin Teva'}},{'repository':'','id':'Q29006443','concepturi':'http://www.wikidata.org/entity/Q29006443','title':'Q29006443','pageid':30666271,'url':'//www.wikidata.org/wiki/Q29006443','label':'Ribavirin Teva Pharma B.v.','description':'pharmaceutical product','match':{'type':'label','language':'en','text':'Ribavirin Teva Pharma B.v.'}},{'repository':'','id':'Q27260032','concepturi':'http://www.wikidata.org/entity/Q27260032','title':'Q27260032','pageid':29072987,'url':'//www.wikidata.org/wiki/Q27260032','label':'ribavirin elaidate','description':'chemical compound','match':{'type':'label','language':'en','text':'ribavirin elaidate'}}],'search-continue':7,'success':1}", headers: {})

    possible_descriptions = Lookup::Intervention.possible_descriptions
    impossible_descriptions = Lookup::Intervention.impossible_descriptions
    #search_string = 'ribavirin (sch 18908)'
    search_string = 'ribavirin'
    result = Util::WikiDataManager.new.find_qcode(search_string, possible_descriptions, impossible_descriptions)
    expect(result[:qcode]).to eq('Q421862')
    expect(result[:wiki_description]).to eq('chemical compound')

  end

end
