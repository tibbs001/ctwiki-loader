module Nci
  class AnatomicSite < ActiveRecord::Base
    self.table_name = 'nci.anatomic_sites'
    belongs_to :study, :foreign_key=> 'nct_id'
  end
end
