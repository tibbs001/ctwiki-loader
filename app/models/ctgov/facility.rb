class Facility < StudyRelationship
  self.table_name = 'ctgov.facilities'

  has_many :facility_contacts, autosave: true
  has_many :facility_investigators, autosave: true

  def self.qcode_lookup
    [
      {'Zunyi Medical College' => 'Q8075310'},
      {'Bayer' => 'Q152051'},
      {'Yuzuncu Yıl University' => 'Q3671573'},
      {'Melanoma Institute Australia' => 'Q19875521'},
    ]
    #NCT03754907, Zunyi Medical College, Q8075310
    #NCT03754556, Bayer, Q152051
    #NCT03754283, Yuzuncu Yıl University, Q3671573
    #NCT03754140, Melanoma Institute Australia, Q19875521
  end

  def self.export
    File.open("public/sponsors.txt", "w+") { |f|
      self.all.each { |sponsor|

        med_facility = ['hospital','medical'].each{|term| return true if facility.name.include?(term)}
        if med_facility
          f << "\nLAST\tP2175\t#{qcode}\t/* #{condition.name} */" if !qcode.blank?
        else
          f << "\nLAST\tP2175\t#{qcode}\t/* #{condition.name} */" if !qcode.blank?
        end
      }
    }
  end

end
