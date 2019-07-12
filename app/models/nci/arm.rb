module Nci
  class Arm < ActiveRecord::Base
    self.table_name = 'nci.arms'
    belongs_to :study, :foreign_key=> 'nct_id'
  end
end
