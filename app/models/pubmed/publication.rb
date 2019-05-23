module Pubmed
  class Publication < ActiveRecord::Base
    self.table_name = 'pubmed.publications'

    attr_accessor :xml

    has_many :other_ids, :foreign_key => 'pmid', :dependent => :delete_all

    def initialize(hash={})
      super
      @xml = hash[:xml]
      self.pmid = hash[:pmid]
    end

    def self.populate
      #pmids=Ctgov::StudyReference.where("reference_type='results_reference'").pluck(:pmid).compact
      sample_pmids.each {|pmid|
        not_loaded = (where('pmid=?',pmid).first) == nil
        not_in_wikidata = (Lookup::Publication.where('pmid=?',pmid).first) == nil
        if not_loaded and not_in_wikidata
          xml=Util::Client.new.get_xml_for(pmid)
          new({xml: xml, pmid: pmid}).create
        end
      }
    end

    def create
      ActiveRecord::Base.logger=nil
      p=Pubmed::Publication.where('pmid=?',pmid).first
      p.try(:destroy)
      update(attribs)
      args={:pmid => pmid, :xml => xml}
      self.other_ids=Pubmed::OtherId.create_all_from(args)
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
      value=(xml.xpath('//PubmedArticle').xpath("//#{label}").text).strip
      value=='' ? nil : value
    end

    def self.sample_pmids
       ['20025029',
       '19648180',
       '17923590',
       '30325889',
       '16188811',
       '26473001',
       '26874298',
       '16989935',
       '18492509',
       '11900034',
       '30538976',
       '29895572',
       '15036740',
       '20483522',
       '30262463']
    end

  end
end
