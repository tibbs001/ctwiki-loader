module Nci
  class Disease < ActiveRecord::Base
    self.table_name = 'nci.diseases'
    belongs_to :study, :foreign_key=> 'nct_id'
    has_many :synonyms, :foreign_key => 'disease_code', :class_name => 'DiseaseSynonym', :dependent => :delete_all
    has_many :parents,  :foreign_key => 'disease_code', :class_name => 'DiseaseParent', :dependent => :delete_all
  end
end
