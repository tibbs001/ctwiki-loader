module Ctgov
  class Sponsor < Ctgov::StudyRelationship
    self.table_name = 'ctgov.sponsors'
    scope :named, lambda {|agency| where("name LIKE ?", "#{agency}%" )}
  end
end
