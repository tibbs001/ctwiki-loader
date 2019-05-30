class String
    def is_i?
       /\A[-+]?\d+\z/ === self
    end
end

module Ctgov
  class CalculatedValue < ActiveRecord::Base
    self.table_name = 'ctgov.calculated_values'
    belongs_to :study, :foreign_key => 'nct_id'
  end
end
