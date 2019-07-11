module Nci
  class Masking < ActiveRecord::Base
    self.table_name = 'nci.maskings'
    belongs_to :study, :foreign_key=> 'nct_id'
  end
end
