require 'active_support/all'
module Lookup
  class SuperLookup < ActiveRecord::Base
    self.abstract_class = true;

    def self.populate
      self.populate_for_model(self.source_data)
    end

    def self.populate_for_model(model_type)
      could_not_resolve = []
      already_loaded = (self.existing_rows + self.names_to_ignore.map{|n|n.downcase})
      self.populate_predefined_qcode
      self.unregistered_names(model_type).each { |label|
        if !already_loaded.include?(label.downcase)
          result = Util::WikiDataManager.new.find_qcode(label, possible_descriptions, impossible_descriptions)
        end
        if result
          self.create_entry_for(result)
          puts result
          already_loaded << result[:downcase_name]
        else
          self.create_non_qcode_entry_for(label)
          could_not_resolve << label
        end
      }
      File.open("public/#{model_type.gsub(':','')}_could_not_resolve.txt", "w+") { |f|
        could_not_resolve.each { |term| f << term }
      }
    end

    def self.unregistered_names(model_type=self.source_data)
      already_loaded = (self.existing_rows + self.names_to_ignore.map{|n|n.downcase})
      (model_type.uniq.pluck(:name).map{|n|n.downcase}) - already_loaded
    end

    def self.existing_rows
      self.all.pluck(:downcase_name)
    end

    def self.populate_predefined_qcode
      already_loaded = self.existing_rows
      self.predefined_qcode.each {|key, value|
        new({ :name => key,
              :downcase_name => key.downcase,
              :qcode => value,
              :wiki_description => 'added by ct-wiki'}).save! if !already_loaded.include? key.downcase
        already_loaded << key.downcase
      }
    end

    def self.create_entry_for(attribs)
      self.new(attribs).save!
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
       'ice dancer',
       'ice hockey player',
       'insurgent group',
       'internist',
       'item2',
       'journal',
       'jurist',
       'lake in canada',
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
