module Nci
  class DiseaseParent < ActiveRecord::Base
    self.table_name = 'nci.disease_parents'
    belongs_to :study, :foreign_key=> 'nct_id'
    belongs_to :disease, :foreign_key=> 'disease_code'
  end
end
