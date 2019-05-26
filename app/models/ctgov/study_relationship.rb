require 'active_support/all'
module Ctgov

  class StudyRelationship < ActiveRecord::Base
    self.abstract_class = true;
    attr_accessor :xml, :opts
    belongs_to :study, :foreign_key=> 'nct_id'

  end
end
