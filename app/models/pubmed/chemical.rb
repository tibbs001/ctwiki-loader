module Pubmed
  class Chemical < PubRelationship
    self.table_name = 'pubmed.chemicals'

    def self.create_all_from(args)
      entities=args[:xml].xpath('//Chemical').collect{|xml|
         new( {:pmid            => args[:pmid],
               :registry_number => xml.xpath('RegistryNumber').text.strip,
               :ui              => xml.xpath('NameOfSubstance').attribute('UI').try(:value),
               :name            => xml.xpath('NameOfSubstance').text.strip
         })
      }
      import(entities)
      return entities
    end

  end
end
