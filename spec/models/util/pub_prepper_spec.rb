require 'rails_helper'

describe Util::PubPrepper do

  it "should retrieve source data from the correct tables" do
    # data source method should return a Publication-type that answers to nct_id.  Would raise an error if no nct_id
    expect(Util::PubPrepper.source_model_name.new({}).pmid).to be(nil)
  end

end
