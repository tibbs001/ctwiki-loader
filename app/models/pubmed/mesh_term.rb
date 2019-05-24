module Pubmed
  class MeshTerm < PubRelationship
    self.table_name = 'pubmed.mesh_terms'

    def self.create_all_from(args)
      entities=args[:xml].xpath('//MeshHeading').collect{|xml|
        val=xml.xpath('DescriptorName')
        qualifier=xml.xpath('QualifierName')
        if !qualifier.blank?
          q_name = qualifier.text.strip
          q_ui   = qualifier.attribute('UI').try(:value)
          q_mt   = (qualifier.attribute('MajorTopicYN').try(:value) == 'Y')
        end

        new( {:pmid                   => args[:pmid],
               :ui                    => val.attribute('UI').try(:value),
               :major_topic           => (val.attribute('MajorTopicYN').try(:value) == 'Y'),
               :name                  => val.text.strip,
               :qualifier_name        => (q_name if q_name),
               :qualifier_ui          => (q_ui if q_ui),
               :qualifier_major_topic => (q_mt if q_mt)
        })
      }
      import(entities)
      return entities
    end

  end
end
