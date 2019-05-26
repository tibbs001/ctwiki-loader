module Pubmed
  class Publication < ActiveRecord::Base
    self.table_name = 'pubmed.publications'

    attr_accessor :xml, :lookup_mgr

    has_many :authors,    :foreign_key => 'pmid', :dependent => :delete_all
    has_many :chemicals,  :foreign_key => 'pmid', :dependent => :delete_all
    has_many :grants,     :foreign_key => 'pmid', :dependent => :delete_all
    has_many :mesh_terms, :foreign_key => 'pmid', :dependent => :delete_all
    has_many :other_ids,  :foreign_key => 'pmid', :dependent => :delete_all
    has_many :types,      :foreign_key => 'pmid', :dependent => :delete_all

    def self.initialize(hash={})
      puts "in pubmed::publication.initializer"
      super
      @xml = Nokogiri::XML(hash[:xml]).css("PubmedArticle").to_xml
      @lookup_mgr = hash[:lookup_mgr]
      self.pmid = hash[:pmid]
    end

    def create
      ActiveRecord::Base.logger=nil
      existing=Pubmed::Publication.where('pmid=?',self.pmid).first
      existing.try(:destroy)
      update(attribs)
      args={:pmid => pmid, :xml => xml}
      self.authors    = Pubmed::Author.create_all_from(args)
      self.chemicals  = Pubmed::Chemical.create_all_from(args)
      self.grants     = Pubmed::Grant.create_all_from(args)
      self.mesh_terms = Pubmed::MeshTerm.create_all_from(args)
      self.other_ids  = Pubmed::OtherId.create_all_from(args)
      self.types      = Pubmed::Type.create_all_from(args)
      self
    end

    def attribs
      date_info = get_date_info('//PubDate')
      country_info = get_country_info
      {
        :issn                  => get('ISSN'),
        :volume                => get('Volume'),
        :issue                 => get('completion_date'),
        :nlm_unique_id         => get('NlmUniqueID'),
        :published_in          => get('Title'),
        :publication_year      => (date_info[:year]      if date_info[:year]),
        :publication_month     => (date_info[:month]     if date_info[:month]),
        :publication_day       => (date_info[:day]       if date_info[:day]),
        :publication_date      => (date_info[:full_date] if date_info[:full_date]),
        :publication_date_str  => (date_info[:date_str]  if date_info[:date_str]),
        :title                 => get('ArticleTitle'),
        :country               => (country_info[:name]   if country_info[:name]),
        :country_qcode         => (country_info[:qcode]  if country_info[:qcode]),
        :pagination            => get('MedlinePgn'),
        :abstract              => get('AbstractText'),
      }
    end

    def get_country_info
      info={}
      name = get('MedlineJournalInfo','Country')
      if !name.blank?
        info[:name]  = name
        info[:qcode] = @lookup_mgr.countries[name]
      end
      return info
    end

    def get_date_info(label)
      info={}
      date_xml = xml.xpath('//PubmedArticle').xpath(label)
      info[:year]  = date_xml.xpath('Year').try(:text)
      month_string = date_xml.xpath('Month').try(:text)
      info[:day]   = date_xml.xpath('Day').try(:text)
      if !month_string.blank?
        info[:month] = Date::ABBR_MONTHNAMES.index(month_string)
        info[:month] = Date::MONTHNAMES.index(month_string)  if info[:month].blank?
      end
      if !month_string.blank? and !info[:day].blank?
        info[:full_date]  = DateTime.parse("#{info[:year]}-#{month_string}-#{info[:day]}").to_date
      end

      info[:date_str] = ''
      info[:date_str] << "#{info[:year]} "  if info[:year]
      info[:date_str] << "#{month_string} " if month_string
      info[:date_str] << "#{info[:day]} "   if info[:day]
      info[:date_str] = info[:date_str].strip
      return info
    end

    def get(label,sublabel=nil)
      if !sublabel.blank?
        pre_value=xml.xpath('//PubmedArticle').xpath("//#{label}")
        value = pre_value.xpath(sublabel).text.strip if !pre_value.blank?
      else
        value = (xml.xpath('//PubmedArticle').xpath("//#{label}").text).strip
      end
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
