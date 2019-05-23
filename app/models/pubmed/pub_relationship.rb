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

    def create_from(opts={})
      @opts = opts
      @xml = opts[:xml] || opts
      self.nct_id=opts[:nct_id]
      a=attribs
      if a.nil?
        return nil
      else
        assign_attributes(a)
      end
      self
    end

    def get(label)
      value=(xml.xpath("#{label}").text).strip
      value=='' ? nil : value
    end

    def get_text(label)
      str=''
      nodes=xml.xpath("//#{label}")
      nodes.each {|node| str << node.xpath("textblock").text}
      str
    end

    def get_child(label)
      xml.children.collect{|child| child.text if child.name==label}.compact.first
    end

    def get_attribute(label)
      xml.attribute(label).try(:value) if !xml.blank?
    end

    def integer_in(str)
      str.scan(/[0-9]/).join.to_i if !str.blank?
    end

    def self.integer_in(str)
      str.scan(/[0-9]/).join.to_i if !str.blank?
    end

    def self.trim(str)
      str.tr("\n\t ", "")
    end

    def get_opt(label)
      @opts[label.to_sym]
    end

    def get_type(label)
      node=xml.xpath("//#{label}")
      node.attribute('type').try(:value) if !node.blank?
    end

    def get_boolean(label)
      val=xml.xpath("//#{label}").try(:text)
      return nil if val.blank?
      return true  if val.downcase=='yes' || val.downcase=='y' || val.downcase=='true'
      return false if val.downcase=='no' || val.downcase=='n' || val.downcase=='false'
    end

    def get_phone
      ext = get('phone_ext')
      return "#{get('phone')} ext #{ext}" if !ext.blank?
      get('phone')
    end

  end
end
