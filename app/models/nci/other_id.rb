module Nci
  class OtherId < ActiveRecord::Base
    self.table_name = 'nci.other_ids'
    belongs_to :study, :foreign_key=> 'nct_id'

  end
end
