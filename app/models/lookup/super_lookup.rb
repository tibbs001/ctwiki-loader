require 'active_support/all'
module Lookup
  class SuperLookup < ActiveRecord::Base
    self.abstract_class = true;

    def self.populate
      self.populate_for_model(self.source_data)
    end

    def self.populate_for_model(model_type)
      could_not_resolve = []
      mgr = Util::WikiDataManager.new
      already_loaded = (self.existing_rows + self.names_to_ignore.map{|n|n.downcase})
      self.populate_predefined_qcode
      self.unregistered_names(model_type).each { |term|
        existing = where("name = ?", term)
        if existing.size == 0
          if !already_loaded.include?(term.downcase)
            result = search_for_qcode(term)
          end
          if result
            obj = self.create_entry_for(result)
            obj.populate_other_attribs
            obj.types = mgr.types_for_qcode(obj.qcode)
            obj.save!
            already_loaded << result[:downcase_name]
          else
            self.create_non_qcode_entry_for(term)
            could_not_resolve << term
          end
        end
      }
    end

    def self.search_for_qcode(term)
      Util::WikiDataManager.new.find_qcode(term, possible_descriptions, impossible_descriptions)
    end

    def self.all_labels
      (model_type.uniq.pluck(self.label).compact.map{|n|n.downcase})
    end

    def self.unregistered_names(model_type=self.source_data)
      already_loaded = (self.existing_rows + self.names_to_ignore.map{|n|n.downcase})
      self.all_labels - already_loaded
    end

    def self.existing_rows
      self.all.pluck(:downcase_name)
    end

    def self.populate_predefined_qcode
      mgr=Util::WikiDataManager.new
      already_loaded = self.existing_rows
      self.predefined_qcode.each {|key, value|
        if !already_loaded.include? key.downcase
          obj = new({ :name => key,
                :downcase_name => key.downcase,
                :qcode => value,
                :types => mgr.types_for_qcode(value),
                :wiki_description => 'added by ct-wiki'})
          obj.populate_other_attribs
          obj.save!
          already_loaded << key.downcase
        end
      }
    end

    def self.create_entry_for(attribs)
      obj=self.new(attribs)
    end

    def populate_other_attribs
      # hook method for subclasses
    end

    def self.create_non_qcode_entry_for(name)
      #  so we know we looked into this one and couldn't find a qcode
      self.new({:name => name, :downcase_name => name.downcase}).save!
    end

    def self.qcode_for(search_name)
      results = self.where('qcode is not null and downcase_name = ?',search_name.downcase)
      results.first.qcode if results.size > 0
    end

    def self.source_data
      # The ctgov model that will be used as the source of info
      # Subclasses might override.
      self.name.split(':').last.constantize
    end

    def self.label
      :name
    end

    def self.names_to_ignore
      #  superclass - subclass should override
      []
    end

    def self.possible_descriptions
      #  superclass - subclass should override
      []
    end

    def self.impossible_descriptions
      [
       'actor',
       'actress',
       'airport',
       'album',
       'archer',
       'army general',
       'article',
       'artistic style',
       'assurer',
       'baby food brand',
       'biochemist',
       'businessman',
       'cardiologist',
       'choir director',
       'competitor',
       'composer',
       'comedian',
       'footballer',
       'daughter of zoroaster',
       'device to suck up dirt',
       'division of plants',
       'doctoral thesis',
       'e-do',
       'encryption device',
       'entrepreneur',
       'family name',
       'family of operating systems',
       'film',
       'fleet of the ',
       'forms of media',
       'footballer',
       'football',
       'former café',
       'freight train',
       'grammar',
       'highway in',
       'hill in',
       'ice dancer',
       'ice hockey player',
       'insurgent group',
       'internist',
       'item2',
       'jurist',
       'lake in',
       'local computer bus',
       'manufacturer',
       'mathematician',
       'memoir',
       'metal band',
       'metro station',
       'missionary',
       'mountain',
       'musician',
       'operating systems',
       'patient',
       'painting',
       'philosopher',
       'physician',
       'player',
       'poet',
       'political system',
       'politician',
       'professor',
       'president',
       'priest',
       'publication',
       'publisher',
       'race car',
       'read-only memory',
       'radio band',
       'real estate company',
       'region in',
       'researcher',
       'river in',
       'road in',
       'teacher',
       'television series',
       'theater',
       'singer',
       'species of ',
       'storage device',
       'street',
       'video game',
       'village in',
       'wikinews article',
       'wikimedia list article',
       'writer',
       'zoroaster',
      ]
    end

  end
end
