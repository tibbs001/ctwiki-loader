module Nci
  class AssociatedStudy < ActiveRecord::Base
    self.table_name = 'nci.associated_studies'
    belongs_to :study, :foreign_key=> 'nct_id'
  end
end
