module Nci
  class Disease < ActiveRecord::Base
    self.table_name = 'nci.diseases'
    belongs_to :study, :foreign_key=> 'nct_id'
  end
end
