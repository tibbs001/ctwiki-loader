module Pubmed
  class Author < PubRelationship
    self.table_name = 'pubmed.authors'

    def self.create_all_from(args)
      entries=args[:xml].xpath('//Author').collect {|xml|
          fname = xml.xpath('ForeName').text.strip
          lname = xml.xpath('LastName').text.strip
          name  = "#{fname} #{lname}"
          new( {:pmid    => args[:pmid],
                :validated  => (xml.attribute('ValidYN').try(:value) == 'Y'),
                :initials   => xml.xpath('Initials').text.strip,
                :orcid      => get_orcid(xml),
                :first_name => fname,
                :last_name  => lname,
                :name       => name,
                :downcase_name => name.downcase
          })
      }.flatten
      import(entries)
      return entries
    end

    def self.get_orcid(xml)
      other_id=xml.xpath('Identifier')
      if !other_id.blank?
        id_type = other_id.attribute('Source').to_s
        if id_type == "ORCID"
          val=other_id.text
          val.slice! 'http://orcid.org/'
          val.slice! 'https://orcid.org/'
          return val
        end
      end
    end

  end
end
