module Util
  class Prepper

    attr_accessor :f, :mgr, :source_obj, :start_num, :end_num, :batch_of_ids, :subject, :new_line, :tab, :space_char, :double_quote_char, :forward_slash_char, :batch_size, :wikidata_ids, :loaded_ids

    def initialize(args={})
      @batch_size = args[:batch_size] || 1000
      @start_num = args[:start_num].to_i || 1
      delimiters = args[:delimiters]
      #delimiters = {:new_line=>'||', :tab=>'|', :space_char=>'%20', :double_quote_char=>'%22', :forward_slash_char=>'%2F'} if delimiters.blank?
      delimiters = {:new_line=>'
', :tab=>'	', :space_char=>' ', :double_quote_char=>'"', :forward_slash_char=>'/'} if delimiters.blank?
      @new_line = delimiters[:new_line]
      @tab = delimiters[:tab]
      @space_char = delimiters[:space_char]
      @double_quote_char = delimiters[:double_quote_char]
      @forward_slash_char = delimiters[:forward_slash_char]
    end

    def self.run(start_num)
      cntr = start_num
      until cntr > source_model_name.count do
        new({:start_num => cntr}).run
        cntr = cntr + batch_size
        sleep(10.minutes)
      end
    end

    def run
      # Iterate over a collection of objects of one type & create a file containing quickstatements
      # that can be loaded into wikidata via the url: https://tools.wmflabs.org/quickstatements/#/batch

      # When loading whole objects, the block of quickstatements will start with a 'CREATE' line.
      # After that, the subject on each line just needs to be 'LAST'
      @subject = 'LAST'
      @loaded_ids = mgr.nctids_in(wikidata_ids)  # IDs of the objects currently  in wikidata - no need to load these
      @end_num = start_num + batch_size  # the website can only handle batches of quickstatements of bout 1,000 objects
      @batch_of_ids = (source_model_name.all_ids - loaded_ids)[start_num..end_num]
      @f=File.open("public/#{start_num}_quickstatements.txt", "w+")
      puts "rest is subclass responsibility"
    end

    def lines_for(prop_code)
      source_obj.quickstatement_for(prop_code, prefix_for(prop_code))
    end

    def prefix_for(prop_code)
      return "#{new_line}#{subject}#{tab}#{prop_code}#{tab}"
    end

  end
end
