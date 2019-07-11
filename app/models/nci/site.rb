module Nci
  class Site < ActiveRecord::Base
    self.table_name = 'nci.sites'
    belongs_to :study, :foreign_key=> 'nct_id'
  end
end
