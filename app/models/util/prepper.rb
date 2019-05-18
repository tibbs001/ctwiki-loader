module Util
  class Prepper

    attr_accessor :mgr, :source_entity, :start_num, :subject, :new_line, :tab, :space_char, :double_quote_char, :forward_slash_char, :batch_size, :wikidata_ids

    def initialize(args={})
      @batch_size = 1000
      @start_num = args[:start_num] || 1
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
      @batch_size ||= 1000
      cntr = start_num.to_i
      until cntr > data_source.count do
        self.new({:start_num => cntr}).run
        cntr = cntr + batch_size
        sleep(10.minutes)
      end
    end

    def run(delimiters=nil)
      @start_num ||=1
      @subject = 'LAST'
      puts "rest is subclass responsibility"
    end

    def lines_for(prop_code)
      @source_entity.quickstatement_for(prop_code, prefix_for(prop_code))
    end

    def prefix_for(prop_code)
      return "#{new_line}#{subject}#{tab}#{prop_code}#{tab}"
    end

    def quickstatement_date(dt, dt_str)
      # TODO Refine date so it has month precision when the day isn't provided
      # TODO Add qualifiers for Anticipated vs Actual
      #Time values must be in format  +1967-01-17T00:00:00Z/11.  (/11 means day precision)
      if dt_str.count(' ') == 1  # if only one space in the date string, it must not have a day, so set to month precision.
        "#{dt}T00:00:00Z/10"
      else
        "#{dt}T00:00:00Z/11"
      end
    end

    def assign_existing_studies_missing_prop(code)
      File.open("public/assign_#{code}.txt", "w+") do |f|
        mgr.ids_for_studies_without_prop(code).each {|hash|
          @source_entity = data_source.where('nct_id=?', hash.keys.first).first
          @subject = hash.values.first
          f << lines_for(code) if source_entity
        }
      end
    end

    def assign_min_max_age(f)
      # year/month unit is identified by appending 'U' to the integer of the year or month Q-value, and
      # tacking it onto the end of the actual value
      min = source_entity.minimum_age.split(' ')
      max = source_entity.maximum_age.split(' ')

      f << "#{new_line}#{subject}#{tab}P2899#{tab}#{min[0]}U577" if min[1] && min[1].downcase == 'years'
      f << "#{new_line}#{subject}#{tab}P4135#{tab}#{max[0]}U577" if max[1] && max[1].downcase == 'years'
      f << "#{new_line}#{subject}#{tab}P2899#{tab}#{min[0]}U5151" if min[1] && min[1].downcase == 'months'
      f << "#{new_line}#{subject}#{tab}P4135#{tab}#{max[0]}U5151" if max[1] && max[1].downcase == 'months'
    end

    def get_qcode_for_url(url)
      # API call to get qcode for url
    end

    def create_research_design(f)
      f << 'CREATE'
      f << "#{new_line}#{subject}#{tab}P31#{tab}Q1438035"   # instance of research design
      f << "#{new_line}#{subject}#{tab}?????#{tab}en:\"#{source_entity.design.intervention_for_wiki}\""
    end

    def assign_facility_qcodes(f)
      source_entity.facilities.each{ |facility|
        qcode = Lookup::Organization.qcode_for(facility.name)
        f << "#{new_line}#{subject}#{tab}P6153#{tab}#{qcode}" if !qcode.blank?
      }
    end

    def assign_keyword_qcodes(f)
      source_entity.keywords.each{ |keyword|
        qcode = Lookup::Keyword.qcode_for(keyword.name)
        #topics are: Q200801
        f << "#{new_line}#{subject}#{tab}P921#{tab}#{qcode}" if !qcode.blank?
      }
    end

    def assign_condition_qcodes(f)
      assigned_qcodes=[]
      conditions = source_entity.browse_conditions.pluck(:downcase_mesh_term).uniq
      conditions.each{ |condition|
        qcode = Lookup::Condition.qcode_for(condition)
        if !qcode.blank? and !assigned_qcodes.include?(qcode)
          f << "#{new_line}#{subject}#{tab}P1050#{tab}#{qcode}"
          assigned_qcodes << qcode
        end
      }
    end

    def assign_country_qcodes(f)
      assigned_qcodes=[]
      source_entity.active_countries.each{ |country|
        qcode = Lookup::Country.qcode_for(country.name)
        if !qcode.blank? and !assigned_qcodes.include?(qcode)
          f << "#{new_line}#{subject}#{tab}P17#{tab}#{qcode}" if !qcode.blank?
          assigned_qcodes << qcode
        end
      }
    end

    def assign_intervention_qcodes(f)
      assigned_qcodes=[]
      interventions = source_entity.browse_interventions.pluck(:downcase_mesh_term).uniq
      interventions.each{ |intervention|
        qcode = Lookup::Intervention.qcode_for(intervention)
        if !qcode.blank? and !assigned_qcodes.include?(qcode)
          f << "#{new_line}#{subject}#{tab}P4844#{tab}#{qcode}" if !qcode.blank?
          assigned_qcodes << qcode
        end
      }
    end

    def assign_urls(f)
      source_entity.documents.each{ |ref|
        f << "#{new_line}#{subject}#{tab}P854#{tab}\"https://www.ncbi.nlm.nih.gov/pubmed/?term=#{ref.url}\"" if !ref.url.blank?
      }
    end

    def assign_pubmed_ids(f)
      puts "Study has #{@source_entity.references.size} publications"
      @source_entity.study_references.each{ |ref|
        #if ref.reference_type=='results_reference'
          pub_qcode = Lookup::Publication.qcode_for(ref.pmid)
          puts "pub qcode is #{pub_qcode}"
          if !pub_qcode.blank?
            # Link pub to study
            f << "#{new_line}#{pub_qcode}#{tab}P921#{tab}#{subject}"
            # Link study to pub
            f << "#{new_line}#{subject}#{tab}P248#{tab}#{pub_qcode}"
          end
        #end
      }
    end

    def assign_sponsor_qcodes(f)
      already_assigned_to_this_study=[]
      source_entity.lead_sponsors.each{ |sponsor|
        qcode = Lookup::Sponsor.qcode_for(sponsor.name)
        if !qcode.blank? and !already_assigned_to_this_study.include?(qcode)
          f << "#{new_line}#{subject}#{tab}P859#{tab}#{qcode}" if !qcode.blank?
          already_assigned_to_this_study << qcode
        end
      }
    end

    def assign_collaborators_qcodes(f)
      already_assigned_to_this_study=[]
      source_entity.collaborators.each{ |sponsor|
        qcode = Lookup::Sponsor.qcode_for(sponsor.name)
        if !qcode.blank? and !already_assigned_to_this_study.include?(qcode)
          f << "#{new_line}#{subject}#{tab}P767#{tab}#{qcode}" if !qcode.blank?
          already_assigned_to_this_study << qcode
        end
      }
    end

  end
end
