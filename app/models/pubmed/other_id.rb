module Pubmed
  class OtherId < PubRelationship
    self.table_name = 'pubmed.other_ids'

    def self.create_all_from(args)
      ids=args[:xml].xpath('//ArticleId').collect{|xml|
         new( {:pmid    => args[:pmid],
              :id_value => xml.text.strip,
              :id_type  => xml.attribute('IdType').try(:value)
         })
      }
      import(ids)
      return ids
    end

  end
end
