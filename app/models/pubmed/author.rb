module Pubmed
  class Author < PubRelationship
    self.table_name = 'pubmed.authors'

    def self.create_all_from(args)
      entries=args[:xml].xpath('//Author').collect {|xml|
          fname = xml.xpath('ForeName').text.strip
          lname = xml.xpath('LastName').text.strip
          name  = "#{fname} #{lname}"
          other_id=xml.xpath('Identifier')
          orcid = other_id.text.strip if other_id and other_id.try(:value) == 'ORCID'

          new( {:pmid    => args[:pmid],
                :validated  => (xml.attribute('ValidYN').try(:value) == 'Y'),
                :initials   => xml.xpath('Initials').text.strip,
                :orcid      => orcid,
                :first_name => fname,
                :last_name  => lname,
                :name       => name,
                :downcase_name => name.downcase
          })
      }.flatten
      import(entries)
      return entries
    end

  end
end
