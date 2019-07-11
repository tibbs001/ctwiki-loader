module Nci
  class PrimaryPurpose < ActiveRecord::Base
    self.table_name = 'nci.primary_purposes'
    belongs_to :study, :foreign_key=> 'nct_id'
  end
end
