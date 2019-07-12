module Nci
  class EligibilityInfo < ActiveRecord::Base
    self.table_name = 'nci.eligibility_info'
    belongs_to :study, :foreign_key=> 'nct_id'
  end
end
