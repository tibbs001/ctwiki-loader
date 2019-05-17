module Wikidata
  class Publication < ActiveRecord::Base
    self.table_name = 'wikidata.publications'

    attr_accessor :xml

    def initialize(hash={})
      super
      @xml = hash[:xml]
      self.pmid = hash[:pmid]
    end

    def create
      ActiveRecord::Base.logger=nil
      p=Wikidata::Publication.where('pmid=?',pmid).first
      p.try(:destroy)
      update(attribs)
      self
    end

    def attribs
      {
        :issn             => get('ISSN'),
        :volume           => get('Volume'),
        :issue            => get('completion_date'),
        :published_in     => get('Title'),
        #:publication_date => get('primary_completion_date'),
        :title            => get('ArticleTitle'),
        :pagination       => get('MedlinePgn'),
        :abstract         => get('AbstractText'),
      }
    end

    def get(label)
      value=(xml.xpath('//Article').xpath("//#{label}").text).strip
      value=='' ? nil : value
    end

  end
end
