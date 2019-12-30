require 'rails_helper'

describe Lookup::Publication do
  it "should find the right qcode for ribavirin with a suffix" do

    stub_request(:get, "https://www.wikidata.org/w/api.php?action=wbsearchentities&format=json&language=en&search=modern+treatment+of+metastatic+hormone-sensitive").
         with(
           headers: {
         'Accept'=>'*/*',
         'Accept-Encoding'=>'gzip, deflate',
         'Host'=>'www.wikidata.org',
         'User-Agent'=>'rest-client/2.0.2 (darwin18.7.0 x86_64) ruby/2.4.5p335'
           }).
         to_return(status: 200, body: "{'searchinfo':{'search':'modern treatment of metastatic hormone-sensitive'},'search':[{'repository':'','id':'Q57190478','concepturi':'http://www.wikidata.org/entity/Q57190478','title':'Q57190478','pageid':57107555,'url':'//www.wikidata.org/wiki/Q57190478','label':'Modern treatment of metastatic hormone-sensitive prostate cancer','description':'scholarly article','match':{'type':'label','language':'en','text':'Modern treatment of metastatic hormone-sensitive prostate cancer'}}],'success':1}", headers: {})

    pmid='27931202'
    search_string = 'modern treatment of metastatic hormone-sensitive'
    possible_descriptions=[]
    impossible_descriptions=[]
    result = Util::WikiDataManager.new.find_qcode(search_string, possible_descriptions, impossible_descriptions)
    expect(result[:qcode]).to eq('Q57190478')
    expect(result[:wiki_description]).to eq('scholarly article')

  end

end
