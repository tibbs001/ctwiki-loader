module Nci
  class Collaborator < ActiveRecord::Base
    self.table_name = 'nci.collaborators'
    belongs_to :study, :foreign_key=> 'nct_id'
  end
end
