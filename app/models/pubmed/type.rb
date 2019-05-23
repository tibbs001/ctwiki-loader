module Pubmed
  class Type < PubRelationship
    self.table_name = 'pubmed.types'

    def self.create_all_from(args)
      entities=args[:xml].xpath('//PublicationType').collect{|xml|
         new( {:pmid  => args[:pmid],
               :ui    => xml.attribute('UI').try(:value),
               :name  => xml.text.strip
         })
      }
      import(entities)
      return entities
    end

  end
end
