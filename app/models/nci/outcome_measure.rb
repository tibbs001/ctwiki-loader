module Nci
  class OutcomeMeasure < ActiveRecord::Base
    self.table_name = 'nci.outcome_measures'
    belongs_to :study, :foreign_key=> 'nct_id'
  end
end
