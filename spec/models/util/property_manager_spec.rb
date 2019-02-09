require 'rails_helper'

describe Util::PropertyManager do

  xit "should return correct value for a given wikidata property code" do
    wikidata_study='NCT03055247'
    mgr=Util::WikiDataManager.new
    expect(mgr.study_already_loaded?(wikidata_study)).to be(true)
    non_wikidata_study='non_existent_nct_id'
    expect(mgr.study_already_loaded?(non_wikidata_study)).to be(false)
  end

end
