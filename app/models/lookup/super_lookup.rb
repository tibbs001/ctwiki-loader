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

    def self.qcode_for(search_name)
      results = self.where('downcase_name = ?',search_name.downcase)
      results.first.qcode if results.size > 0
    end

    def self.source_data
      # The ctgov model that will be used as the source of info
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
       'army general',
       'article',
       'artistic style',
       'basketball player',
       'composer',
       'device to suck up dirt',
       'division of plants',
       'doctoral thesis',
       'encryption device',
       'family name',
       'family of operating systems',
       'film',
       'insurgent group',
       'item2',
       'journal',
       'lake in canada',
       'local computer bus',
       'manufacturer',
       'memoir',
       'metal band',
       'mountain in mongolia',
       'musician',
       'operating systems',
       'painting',
       'publication',
       'publisher',
       'race car',
       'read-only memory',
       'radio band',
       'researcher',
       'river in',
       'road in',
       'storage device',
       'video game',
       'zoroaster',
      ]
    end

  end
end
