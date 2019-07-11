module Nci
  class Keyword < ActiveRecord::Base
    self.table_name = 'nci.keywords'
    belongs_to :study, :foreign_key=> 'nct_id'
  end
end
