require 'rails_helper'

describe Util::Eraser do

  xit "should return array of quickstatement lines for given study/property" do
    stub_request(:post, "https://query.wikidata.org/sparql").
         with(
           body: {"query"=>"SELECT ?item WHERE { ?item wdt:P3098 'NCT03215810' . } "},
           headers: {
       	  'Accept'=>'application/sparql-results+json, application/sparql-results+xml, text/boolean, text/tab-separated-values;q=0.8, text/csv;q=0.2, */*;q=0.1',
       	  'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
       	  'Connection'=>'keep-alive',
       	  'Content-Type'=>'application/x-www-form-urlencoded',
       	  'Keep-Alive'=>'120',
       	  'User-Agent'=>'Ruby'
           }).
       to_return(status: 200, body: [RDF::Query::Solution.new({:item=>RDF::URI.new('http://www.wikidata.org/entity/Q60501336')})], headers: {})

    nct_id='NCT03215810'
    prop='P2175'
    result = described_class.new.create_erase_commands(nct_id, prop)
    expect(result).to be('????')
  end

end
