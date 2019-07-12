module Nci
  class Study < ActiveRecord::Base
    self.table_name = 'nci.studies'
    self.primary_key = 'nct_id'

    has_one  :bio_specimen,       :foreign_key => 'nct_id', :dependent => :destroy
    has_one  :central_contact,    :foreign_key => 'nct_id', :dependent => :destroy
    has_one  :eligibility,        :foreign_key => 'nct_id', :dependent => :destroy
    has_one  :masking,            :foreign_key => 'nct_id', :dependent => :destroy
    has_one  :phase,              :foreign_key => 'nct_id', :dependent => :destroy
    has_one  :primary_purpose,    :foreign_key => 'nct_id', :dependent => :destroy

    has_many :anatomic_sites,     :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :arms,               :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :associated_studies, :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :biomarkers,         :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :collaborators,      :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :diseases,           :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :eligibility_criteria, :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :keywords,           :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :other_ids,          :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :outcome_measures,   :foreign_key => 'nct_id', :dependent => :delete_all
    has_many :sites,              :foreign_key => 'nct_id', :dependent => :delete_all

    accepts_nested_attributes_for :anatomic_sites, :associated_studies, :diseases, :outcome_measures

    def tags
      ['arms', 'associated_studies','anatomic_sites','biomarkers','collaborators','diseases','eligibility','keywords','other_ids', 'sites']
    end

    def initialize(params={})
      data = params
      # remove empty tags
      tags.each{ |tag| data.except!(tag) if params[tag].nil? }
      nct_id=data['nct_id']
      puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
      puts nct_id
      puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

      # create one-to-one related objects
      data["bio_specimen"]       = Nci::BioSpecimen.new(data['bio_specimen'].merge({'nct_id'=>nct_id}))  if data['bio_specimen']
      data["central_contact"]    = Nci::CentralContact.new(data['central_contact'].merge({'nct_id'=>nct_id})) if data['central_contact']
      data["masking"]            = Nci::Masking.new(data['masking'].merge({'nct_id'=>nct_id}))  if data['masking']
      data["phase"]              = Nci::Phase.new(data['phase'].merge({'nct_id'=>nct_id}))  if data['phase']
      data["primary_purpose"]    = Nci::PrimaryPurpose.new(data['primary_purpose'].merge({'nct_id'=>nct_id}))  if data['primary_purpose']

      # create one-to-many related objects
      data["arms"]               = data["arms"].map {|as| Nci::Arm.new(as.except('interventions').merge({'nct_id'=>nct_id}))}  if data['arms']
      data["anatomic_sites"]     = data["anatomic_sites"].map {|as| Nci::AnatomicSite.new({:nct_id=>nct_id,:name=>as})} if data['anatomic_sites']
      data["associated_studies"] = data["associated_studies"].map {|as| Nci::AssociatedStudy.new(as.merge({'nct_id'=>nct_id}))}  if data['associated_studies']
      data['biomarkers']         = data['biomarkers'].map {|as| Nci::Biomarker.new(as.except!('synonyms').merge({'nct_id'=>nct_id})) } if data['biomarkers']
      data['collaborators']      = data['collaborators'].map {|as| Nci::Collaborator.new(as.merge({'nct_id'=>nct_id}))}  if data['collaborators']
      data["keywords"]           = data["keywords"].map {|keyword| Nci::Keyword.new({'nct_id'=>nct_id, 'name'=>keyword})} if data['keywords']
      data["other_ids"]          = data["other_ids"].map {|as| Nci::OtherId.new(as.merge({'nct_id'=>nct_id}))}  if data['other_ids']
      data["outcome_measures"]   = data["outcome_measures"].map {|as| Nci::OutcomeMeasure.new(as.merge({'nct_id'=>nct_id}))}  if data['outcome_measures']
      data['sites']              = create_site_objects(nct_id, data['sites']) if data['sites']

      data['diseases']           = data['diseases'].map {|d|
        clean_d=d.except!('synonyms','paths','parents','type')
        Nci::Disease.new(clean_d.merge({'nct_id'=>nct_id}))
      } if data['diseases']

      if data['eligibility']['structured']
        data["eligibility"] = Nci::Eligibility.new(data['eligibility']['structured'].merge({'nct_id'=>nct_id}))
      end

      if data['eligibility']['unstructured']
        data['eligibility_criteria'] = data['eligibility']['unstructured'].map {|e|
          Nci::EligibilityCriterium.new(e.merge({'nct_id'=>nct_id}))
        }
      end

      super(data)
    end

    def create_site_objects(nct_id, site_data)
      site_data.map {|site|
        if site['org_coordinates']
          lat=site['org_coordinates']['lat']
          lon=site['org_coordinates']['lon']
          clean_s=site.reject! { |k| k == 'org_coordinates' }
        else
          lat=lon=nil
          clean_s=site
        end
        Nci::Site.new(clean_s.merge({'nct_id'=>nct_id,'lat'=>lat,'lon'=>lon}))
      }
    end

    def self.all_ids
      all.pluck(:nct_id)
    end

    def self.populate
      data = JSON.parse(File.read("public/nci-data.json"))['trials']
      data.compact.each{ |study_data|
        begin
          Nci::Study.create(study_data.except('arms')) if study_data
        rescue
          # If one fails, go on to the next.
        end
      }
    end

    def self.json(num=nil)
      if num.nil?
        JSON.parse(File.read("public/nci-data.json"))['trials']
      else
        JSON.parse(File.read("public/nci-data.json"))['trials'][num]
      end
    end

  end
end
