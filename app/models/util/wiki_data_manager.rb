require 'rubygems'
require 'sparql/client'

module Util
  class WikiDataManager

    def wiki_api_call(search_string, search_strings_tried, delimiter=nil)
      if !search_strings_tried.include?(search_string)
        search_strings_tried << search_string
        if delimiter.blank?
          puts ">>>>>> using initial string: #{search_string}"
        else
          puts ">>>>>> spliting on #{delimiter}: #{search_string}"
        end
        url = "https://www.wikidata.org/w/api.php?action=wbsearchentities&search=#{search_string}&language=en&format=json"
#               https://www.wikidata.org/w/api.php?action=wbsearchentities&search=23153596&language=en&format=json
#               https://www.wikidata.org/w/api.php?action=wbgetentities&format=json&ids=Q18002781
        puts "#{url}"
        begin
          download = RestClient::Request.execute({ url: url, method: :get, content_type: :json})
          eval(download)[:search]
        rescue
          puts "XXXXXXXXXXXXXXXXX ERROR Encountered XXXXXXXXXXXXXXXXXXXXXXXXX"
          puts "skipping search_string: #{search_string} "
          exit
        end
      end
    end

    def delimiters
      [' : ', ',','-', '(' ,'µg' ,'and', ' in ', '+']
    end

    def initialize_search_string(str, should_remove_numbers)
      if should_remove_numbers
        str.gsub!(/%/,"") if str.include?(' mg ') or str.include?(' cc ')
        str.gsub!('injection of ','')
        str.gsub!(/(.\d+|(mg))/,"") if str.include?(' mg ')
        str.gsub!(/(.\d+|(cc of))/,"") if str.include?(' cc of ')
        str.gsub!(/(\d.\d+|(cc))/,"") if str.include?(' cc ')
        str.gsub!('#','')
        return str
      end
    end

    def get_qcode_from_query(query)
      wiki_api_call(search_string, search_strings_tried, delimiter)
    end

    def find_qcode(str, possible_descriptions, impossible_descriptions, should_remove_numbers = true)
      encoding_options = {
        :invalid           => :replace,  # Replace invalid byte sequences
        :undef             => :replace,  # Replace anything not defined in ASCII
        :replace           => '',        # Use a blank for those replacements
        :universal_newline => true       # Always break lines with \n
      }

      #  Yes, there's got to be a better way than this. Just trying to get something quickly working for now.
      begin
        puts ">>>>>>>>>>> Looking up #{str}"
        search_strings_tried=[]
        start_string = initialize_search_string(str, should_remove_numbers)
        search_string = start_string.strip.gsub(' ','+').gsub('++','+').encode(Encoding.find('ASCII'), encoding_options)
        raw_results = wiki_api_call(search_string, search_strings_tried)
        if raw_results.empty?

          c = []
          delimiters.each{ |delimiter|
            puts "  nothing found yet.  Gonna try breaking on #{delimiter}"
            search_string = start_string.split(delimiter).first.strip.gsub(' ','+').gsub('++','+').encode(Encoding.find('ASCII'), encoding_options)
            result = wiki_api_call(search_string, search_strings_tried, delimiter)
            if result.blank?
              search_string = start_string.split(delimiter).last.strip.gsub(' ','+').gsub('++','+').encode(Encoding.find('ASCII'), encoding_options)
              result = wiki_api_call(search_string, search_strings_tried, delimiter)
            else
              c << result
            end
          }

          raw_results = c.flatten.compact
        end
        if raw_results.empty?
          puts "  =============>>>>>> Giving up. #{str}"
          return nil
        end

        results = exclude_impossible_hits(raw_results, impossible_descriptions)
        if results.size == 1
          puts "  #{str}: Got one hit on first try."
          item = results.first
          return { :qcode => item[:id], :name => str, :downcase_name => str.downcase, :wiki_description => item[:description] }
        end

        # If more than one wikidata item found...
        # First check for ones that have an appropriate description
        entries_with_appropriate_descriptions = []
        puts "  #{str}: Multiple hits (#{results.size})."
        results.each{|r| puts "    #{r[:description]}" }
        puts "  Iterating over possible (allowed) descriptions....."
        possible_descriptions.each {|desc|
          puts "     Trying #{desc}..."
          results.each{|x|
            wiki_desc = x[:description].try(:downcase)
            res = wiki_desc.include?(desc) if wiki_desc
            if res
              "    Entries found with description: #{desc}"
              entries_with_appropriate_descriptions << x if res
            end
          }
        }
        return_results=entries_with_appropriate_descriptions.flatten
        return nil if return_results.size == 0
        if return_results.size == 1
          item = return_results.first
          return { :qcode => item[:id], :name => str, :downcase_name => str.downcase, :wiki_description => item[:description] }
        end

        puts "  #{str}: Found #{return_results.size} with appropriate desc."  if return_results.size > 1
        item = return_results.first
        # Next check those with appropriate desc and have an exact match
        exact_label_matches = return_results.select{|entry| entry[:label].try(:downcase) == str.downcase }
        if exact_label_matches.size != 1  # punt - just take first one if no exact label match??
          puts "  #{str}: Multiple labels match exactly. Gonna use first one with an appropriate desc."
          return { :qcode => item[:id], :name => str, :downcase_name => str.downcase, :wiki_description => item[:description] }
        end

        if exact_label_matches.size == 1
          puts "  #{str}: Found one exact label match with an approprate desc: #{item[:description]}."
          item = exact_label_matches.first
          return { :qcode => item[:id], :name => str, :downcase_name => str.downcase, :wiki_description => item[:description] }
        end

        # If there's a tie at this point, should we take the one with the most statements?

      rescue => e
        #  Don't terminate whole process if we have trouble looking for one.
        puts ">>>>>>>>>>>>>>> !!! ERROR looking for #{str}: #{e}"
        exit
      end
    end

    def exclude_impossible_hits(raw_results, impossible_descriptions)
      raw_results.each {|rr|
        impossible_descriptions.each {|impossible|
          if rr and rr[:description] and rr[:description].include? impossible
            rr[:description] = 'delete me'
          end
        }
      }
      return raw_results.select{|x| x[:description] != 'delete me' }
    end

    def get_qcode_for_orcid(orcid)
      #cmd = "SELECT DISTINCT  ?item WHERE { ?item p:P31/ps:P31/wdt:P279* wd:Q191067 . ?item wdt:P698 '#{pmid}'. }"
      cmd = "SELECT DISTINCT  ?item where { ?item wdt:P496 '#{orcid}' }"
      results = run_sparql(cmd)
      return nil if results.empty?
      the_code=nil
      results.first.each_binding {|item| the_code = item.last.value.chomp.split('/').last }
      return the_code
    end

    def get_qcode_for_pmid(pmid)
      cmd = "SELECT DISTINCT  ?item WHERE { ?item p:P31/ps:P31/wdt:P279* wd:Q191067 . ?item wdt:P698 '#{pmid}'. }"
      #cmd = "SELECT DISTINCT ?item WHERE { ?item p:P31/ps:P31/wdt:P279* wd:Q191067 . ?item wdt:P698 '23153596'. }" sample of one in wikidata
      results = run_sparql(cmd)
      return nil if results.empty?
      the_code=nil
      results.first.each_binding {|item| the_code = item.last.value.chomp.split('/').last }
      return the_code
    end

    def get_vals_for(prop)
      cmd = "
        SELECT ?item ?nct_id ?val
        WHERE
        {
           ?item p:P31/ps:P31/wdt:P279* wd:Q30612.
           ?item wdt:P3098 ?nct_id .
           ?item wdt:#{prop} ?val .
        }"

      result = []
      run_sparql(cmd).each {|i|
        label = qcode = nct_id = val = ''
        i.each_binding { |name, item|
          label = name.to_s.split(' ').first.strip
          qcode = item.value.chomp.split('/').last if label == 'item'
          val = item.value.gsub("\n",'').strip if label == 'val'
          nct_id = item.value.gsub("\n",'').strip if label == 'nct_id'
        } if !i.blank?
        result << [qcode, nct_id, prop, val]
      }
      return result.uniq
    end

    def org_properties_for(qcode)
      result=[]
      cmd="SELECT ?qs_world_univ_id ?arwu_univ_id ?times_higher_ed_id ?grid_id ?countryLabel
      WHERE
      { OPTIONAL {  wd:#{qcode}  wdt:P5584  ?qs_world_univ_id }
        OPTIONAL {  wd:#{qcode} wdt:P5242  ?arwu_univ_id }
        OPTIONAL {  wd:#{qcode} wdt:P5586  ?times_higher_ed_id }
        OPTIONAL {  wd:#{qcode} wdt:P2427  ?grid_id }
        OPTIONAL {  wd:#{qcode} wdt:P17    ?country }
        SERVICE wikibase:label { bd:serviceParam wikibase:language \"[AUTO_LANGUAGE],en\". }} "

      run_sparql(cmd).each {|i|
        i.each_binding { |name, item| result << {name=>item.value} } if !i.blank?
      }
      return result.uniq.flatten
    end

    def types_for_qcode(qcode)
      cmd = "SELECT ?typeLabel WHERE { wd:#{qcode} wdt:P31 ?type . SERVICE wikibase:label { bd:serviceParam wikibase:language \"[AUTO_LANGUAGE],en\". } }"

      result = []
      run_sparql(cmd).each {|i|
        i.each_binding { |name, item| result << item.value } if !i.blank?
      }
      return result.uniq.flatten.join(', ')
    end

    def run_sparql(cmd)
      headers={}
      headers['User-Agent'] = 'ctwiki-loader (https://github.com/tibbs001/ctwiki-loader) sheri.tibbs@duke.edu'
      client = SPARQL::Client.new("https://query.wikidata.org/sparql")
      return client.query(cmd)
    end

  end
end
