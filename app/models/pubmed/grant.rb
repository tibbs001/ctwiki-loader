module Pubmed
  class Grant < PubRelationship
    self.table_name = 'pubmed.grants'

    def self.create_all_from(args)
      entities=args[:xml].xpath('//Grant').collect{|xml|
        new( {:pmid      => args[:pmid],
              :grant_id  => xml.xpath('GrantID').text.strip,
              :acronym   => xml.xpath('Acronym').text.strip,
              :agency    => xml.xpath('Agency').text.strip,
              :country   => xml.xpath('Country').text.strip,
        })
      }
      import(entities)
      return entities
    end

  end
end
