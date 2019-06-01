module Util
  class Prepper

    attr_accessor :f, :mgr, :lookup_mgr, :start_num, :end_num, :batch_of_ids, :batch_size, :id_qcode_maps, :loaded_ids

    def initialize(args={})
      #  Example launch:  Util::StudyPrepper.new({:start_num=>'78000'}).run
      #  Example launch:  Util::PubPrepper.new({:start_num=>'8000'}).run
      @batch_size = args[:batch_size] || 1000
      @start_num = args[:start_num].to_i || 1
      @mgr = Util::WikiDataManager.new
      @lookup_mgr = Util::LookupManager.new
      @id_qcode_maps=get_id_maps
    end

    def self.run(args={})
      start_num = args[:start_num] || 0
      batch_size = args[:batch_size] || 1000
      cntr = start_num
      until cntr > source_model_name.count do
        new({:start_num => cntr, :batch_size => batch_size}).run
        cntr = cntr + batch_size
        sleep(1.minute)
      end
    end

    def run(args={})
      # Iterate over a collection of objects of a certain type & create a file containing quickstatements
      # that can be loaded into wikidata via the url: https://tools.wmflabs.org/quickstatements/#/batch

      @loaded_ids = id_qcode_maps.keys  # IDs of the objects currently  in wikidata - no need to load these
      @lookup_mgr = Util::LookupManager.new
      # @loaded_ids set by the subclass - could be NCT IDs (for studies) or PMIDs (for pubs).
      @end_num = @start_num + @batch_size  # the website can only handle batches of quickstatements of about 1,000 objects
      @batch_of_ids = (source_model_name.all_ids - loaded_ids)[start_num..end_num]
      @f=File.open("public/#{start_num}_#{load_type}_quickstatements.txt", "w+")
      cntr = 1
      batch_of_ids.each do |id|
        cntr = cntr + 1
        #begin
          if !loaded_ids.include? id
            obj=source_model_name.get_for(id, @lookup_mgr)
            obj.create_all_quickstatements(f) if obj
            loaded_ids << id
          end
        #rescue => e
        #    loaded_ids << id
        #  puts e
        #  f.close
        #end
      end
      f.close
    end

    def load_type
      source_model_name.to_s.split(':').last.downcase
    end

  end
end
