module Nci
  class Biomarker < ActiveRecord::Base
    self.table_name = 'nci.biomarkers'
    belongs_to :study, :foreign_key=> 'nct_id'
  end
end
