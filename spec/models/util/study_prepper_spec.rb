require 'rails_helper'

describe Util::StudyPrepper do

  it "should retrieve source data from the correct tables" do
    # data source method should return a Study-type that answers to nct_id.  Would raise an error if no nct_id
    expect(Util::StudyPrepper.data_source.new({}).nct_id).to be(nil)
  end

end
