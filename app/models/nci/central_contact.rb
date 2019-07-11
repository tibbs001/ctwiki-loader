module Nci
  class CentralContact < ActiveRecord::Base
    self.table_name = 'nci.central_contacts'
    belongs_to :study, :foreign_key=> 'nct_id'
  end
end
