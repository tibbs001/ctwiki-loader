module Pubmed
  class Publication < ActiveRecord::Base
    self.table_name = 'pubmed.publications'
    self.primary_key = 'pmid'
    include Util::QuickstatementExtension

    attr_accessor :xml, :lookup_mgr

    has_many :authors,    :foreign_key => 'pmid', :dependent => :delete_all
    has_many :chemicals,  :foreign_key => 'pmid', :dependent => :delete_all
    has_many :grants,     :foreign_key => 'pmid', :dependent => :delete_all
    has_many :mesh_terms, :foreign_key => 'pmid', :dependent => :delete_all
    has_many :other_ids,  :foreign_key => 'pmid', :dependent => :delete_all
    has_many :types,      :foreign_key => 'pmid', :dependent => :delete_all

    def self.all_ids
      # These are all the IDs to be loaded into wikidata
      all.pluck(:pmid)
    end

    def self.get_for(id)
      where('pmid=?', id).first.set_delimiters
    end

    def self.initialize(hash={})
      puts "in pubmed::publication.initializer"
      super
      @xml = Nokogiri::XML(hash[:xml]).css("PubmedArticle").to_xml
      @lookup_mgr = hash[:lookup_mgr]
      self.pmid = hash[:pmid]
    end

    def prop_codes
      [
      'Len',    # Label
      'Den',    # Description
      'P31',    # instance of a scholarly article
      'P698',   # pmid
      'P236',   # issn
      'P478',   # volume
      'P433',   # issue
      'P1433',  # published in
      'P1160',  # iso abbreviation
      'P577',   # publication date
      'P407',   # language
      'P1476',  # title
      'P1055',  # nlm unique id  Q57589544
      #'P17',    # country
      #'',  # completion date
      #'',  # revision date
      #'',  # pagination
      #'',  # abstract
      #'',  # country_qcode
      #'',  # issn linking
      #'',  # grants
      #'',  # chemicals
      #'',  # mesh terms
      ]
    end

        def quickstatement_for(prop_code)
      reg_prefix="#{prefix}#{prop_code}#{tab}"
      case prop_code
        when 'Len'
          if title.blank?
            return "#{reg_prefix}\"#{pmid}"  # Label
          else
            return "#{reg_prefix}\"#{title[0..244]}\""  # Label
          end
        when 'Den'
          return "#{reg_prefix}\"scholarly article\""     # Description
        when 'P31'    # instance of
          return "#{reg_prefix}Q13442814"  # or Q191067?  # instance of a scholarly article
        when 'P698'   # pmid
          return "#{reg_prefix}\"#{pmid}\""
        when 'P236'   # issn
          return "#{reg_prefix}\"#{issn}\"" if issn
        when 'P478'   # volume
          return "#{reg_prefix}\"#{volume}\"" if volume
        when 'P433'   # issue
          return "#{reg_prefix}\"#{issue}\"" if issue
        when 'P1160'   # iso abbreviation
          return "#{reg_prefix}\"#{iso_abbreviation}\"" if iso_abbreviation
        when 'P1476'  # title
          return "#{reg_prefix}en:\"#{title}\"" if title
        when 'P577'   # publication date
          return "#{reg_prefix}+#{quickstatement_date(publication_date, publication_year.to_s)}" if publication_date
        when 'P407'  # language
          return "#{reg_prefix}Q1860" if language == 'eng'
        #when 'P1433'   # published in
        #  return published_in_quickstatements
        #when 'P17'    # country
        #  return country_quickstatements if countries.size > 0
     else
        puts "unknown property:  #{prop_code}"
      end
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
