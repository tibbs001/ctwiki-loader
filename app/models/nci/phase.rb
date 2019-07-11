module Nci
  class Phase < ActiveRecord::Base
    self.table_name = 'nci.phases'
    belongs_to :study, :foreign_key=> 'nct_id'
  end
end
