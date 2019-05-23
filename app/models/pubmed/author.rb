module Pubmed
  class Author < PubRelationship
    self.table_name = 'pubmed.authors'

    def self.create_all_from(args)
      entries=args[:xml].xpath('//Author').collect{|xml|
        if xml.attribute('ValidYN').try(:value) == 'Y'
          new( {:pmid    => args[:pmid],
                 :first_name => xml.xpath('ForeName').text.strip,
                 :last_name  => xml.xpath('LastName').text.strip,
                 :initials   => xml.xpath('Initials').text.strip,
                 :affiliation  => xml.xpath('AffiliationInfo').xpath('Affiliation').text.strip,
          })
        end
      }.flatten
      import(entries)
      return entries
    end

  end
end
