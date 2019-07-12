module Nci
  class EligibilityCriterium < ActiveRecord::Base
    self.table_name = 'nci.eligibility_criteria'
    belongs_to :study, :foreign_key=> 'nct_id'
  end
end
