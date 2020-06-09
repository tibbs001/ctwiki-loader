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

    def authors_with_orcid
      authors.where('orcid is not null')
    end

    def self.initialize(hash={})
      super
      #@xml = Nokogiri::XML(hash[:xml]).css("//PubmedArticle").to_xml
      @xml = hash[:xml].xpath("//PubmedArticle").to_xml
      @lookup_mgr = hash[:lookup_mgr]
      self.pmid = hash[:pmid]
    end

    def self.all_ids
      # These are all the IDs to be loaded into wikidata
      all.pluck(:pmid)
    end

    def self.get_for(id, lookup_mgr)
      obj=where('pmid=?', id).first
      obj.set_delimiters
      obj.lookup_mgr=lookup_mgr
      return obj
    end

    def should_be_loaded?
      #  hook method
      true
    end

#  Communication Medium Q340169 <JournalIssue CitedMedium="Print or Internet">

    def prop_codes
      [
      'Len',    # Label
      'Den',    # Description
      'P31',    # instance of a scholarly article
      'P698',   # pmid
      'P356',   # doi
      'P236',   # issn
      'P1433',  # published in
      'P478',   # volume
      'P433',   # issue
      'P1160',  # iso abbreviation
      'P577',   # publication date
      'P407',   # language
      'P1476',  # title
      'P1055',  # nlm unique id  Q57589544
      'P304',   # pagination
      'P921',   # study
      'P2093',  # author names
      'P50',    # authors


      'P6153',  # research site

      #'P2860',  # other publications cited
      #'P17',   # country
      #'',  # completion date
      #'',  # revision date
      #'',  # abstract
      #'',  # country_qcode
      #'',  # issn linking
      #'',  # grants
      'P921',  # chemicals
      'P486',  # mesh DCode
      'OtherIds',  # Other IDs
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
        when 'P356' # DOI
          return "#{reg_prefix}\"#{doi}\"" if doi
        when 'P236'   # issn
          return "#{reg_prefix}\"#{issn}\"" if issn
        when 'P304'   # issn
          return "#{reg_prefix}\"#{pagination}\"" if pagination
        when 'P478'   # volume
          return "#{reg_prefix}\"#{volume}\"" if volume
        when 'P433'   # issue
          return "#{reg_prefix}\"#{issue}\"" if issue
        when 'P1160'   # iso abbreviation
          return "#{reg_prefix}\"#{iso_abbreviation}\"" if iso_abbreviation
        when 'P1476'  # title
          return "#{reg_prefix}en:\"#{title}\"" if title
        when 'P577'   # publication date
          return pub_date_quickstatement(reg_prefix)
        when 'P921'  # link to main topic (the study)
          return study_as_main_topic_quickstatement
        when 'P407'  # language
          return "#{reg_prefix}Q1860" if language == 'eng'
        when 'P486'  # MeSH Codes
          return mesh_code_quickstatements
        when 'OtherIds'  # Other IDs
          return other_id_quickstatements
        when 'P1433'   # published in
          return published_in_quickstatement
        when 'P2093'   # author names
          return author_name_quickstatements
        when 'P50'   # author links
          return author_quickstatements
        #when 'P17'    # country
        #  return country_quickstatements if countries.size > 0
     else
        puts "unknown property:  #{prop_code}"
      end
    end

    def pub_date_quickstatement(reg_prefix)
      str=''
      str << publication_year.to_s if publication_year
      str << " #{publication_month.to_s.rjust(2, "0")}" if publication_month
      str << " #{publication_day.to_s.rjust(2, "0")}" if publication_day
      return "#{reg_prefix}+#{quickstatement_date(publication_date, str)}" if !str.blank?
    end

    def study_as_main_topic_quickstatement
      # only create this snak if the pub is the result of the study (type='results_reference')
      references=Ctgov::Reference.where('pmid=? and reference_type=?',pmid, 'results_reference')
      return if references.size != 1
      nct_id = references.first.nct_id
      study_qcode=lookup_mgr.studies[nct_id]
      "#{new_line}#{subject}#{tab}P921#{tab}#{study_qcode}" if !study_qcode.blank?
    end

    def published_in_quickstatement
      qcode = Lookup::Journal.qcode_for(published_in.downcase) if !published_in.blank?
      "#{new_line}#{subject}#{tab}P1433#{tab}#{qcode}" if !qcode.blank?
    end

    def author_quickstatements
      return_str = ''
      authors_with_orcid.each{ |author|
        author_qcode=lookup_mgr.authors[author.orcid]
        return_str << "#{new_line}#{subject}#{tab}P50#{tab}#{author_qcode}" if !author_qcode.blank?
      }
      return return_str
    end

    def author_name_quickstatements
      return_str = ''
      authors.each{ |author|
        return_str << "#{new_line}#{subject}#{tab}P2093#{tab}\"#{author.name}\"" if author.name.size > 1
      }
      return return_str
    end

    def mesh_code_quickstatements
      return_str = ''
      mesh_terms.each{ |mesh|
        return_str << "#{new_line}#{subject}#{tab}P6153#{tab}#{mesh.ui}" if !mesh.ui.blank? && mesh.major_topic
      }
      return return_str
    end

    def other_id_quickstatements
      return_str = ''
      other_ids.each{ |other|
        return_str << "#{new_line}#{subject}#{tab}P356#{tab}#{other.id_value}" if !other.id_type == 'doi'
      }
      return return_str
    end

    def create
      return if xml.nil?
      ActiveRecord::Base.logger=nil
      existing=Pubmed::Publication.where('pmid=?',self.pmid).first
      existing.try(:destroy)
      args={:pmid => pmid, :xml => xml, :lookup_mgr => lookup_mgr}
      self.authors    = Pubmed::Author.create_all_from(args)
      self.chemicals  = Pubmed::Chemical.create_all_from(args)
      self.grants     = Pubmed::Grant.create_all_from(args)
      self.mesh_terms = Pubmed::MeshTerm.create_all_from(args)
      self.other_ids  = Pubmed::OtherId.create_all_from(args)
      self.types      = Pubmed::Type.create_all_from(args)
      update(attribs)
      self
    end

    def attribs
      date_info = get_date_info('//PubDate')
      country_info = get_country_info
      {
        :issn                  => get('ISSN'),
        :volume                => get('Volume'),
        :issue                 => get('Issue'),
        :nlm_unique_id         => get('NlmUniqueID'),
        :published_in          => get('Title'),
        :name                  => get('Title'),
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
      else
        # Use first of month of day not provided.
        # When creating quickstatements, it will check for presence of 'publication_day' &
        # will create the pub data accordingly
        info[:full_date]  = DateTime.parse("#{info[:year]}-#{month_string}-01").to_date
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

    def doi
      other_ids.select{|i| i.id_type=='doi'}.first.try(:id_value)
    end

  end
end
