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

    def get_country_info
      info={}
      name = get('Country')
      if !name.blank?
        info[:name]  = name
        info[:qcode] = @lookup_mgr.countries[name]
      end
      return info
    end

  end
end
