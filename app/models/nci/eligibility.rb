module Nci
  class Eligibility < ActiveRecord::Base
    self.table_name = 'nci.eligibilities'
    belongs_to :study, :foreign_key=> 'nct_id'
  end
end
