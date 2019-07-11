module Nci
  class BioSpecimen < ActiveRecord::Base
    self.table_name = 'nci.bio_specimens'
    belongs_to :study, :foreign_key=> 'nct_id'
  end
end
