require 'active_support/all'
module Pubmed

  class PubRelationship < ActiveRecord::Base
    self.abstract_class = true;
    attr_accessor :xml
    belongs_to :publication, :foreign_key=> 'pmid'

    def self.create_all_from(args)
      objects=xml_entries(opts).collect{|xml|
        args[:xml]=xml
        new.create_from(args)
      }.compact
      objects
    end

    def self.create_from(args)
      new.conditionally_create_from(args)
    end

    def self.xml_entries(args)
      args[:xml].xpath(top_level_label)
    end

    def get(label)
      value=(xml.xpath("#{label}").text).strip
      value=='' ? nil : value
    end

  end
end
