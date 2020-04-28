module Util
  module QuickstatementExtension

    attr_accessor :delimiters, :subject, :object

    def new_line
      @delimiters[:new_line] || '||'
    end

    def tab
      @delimiters[:tab] || '|'
    end

    def space_char
      @delimiters[:space_char] || '%20'
    end

    def double_quote_char
      @delimiters[:double_quote_char] || '%22'
    end

    def forward_slash_char
      @delimiters[:forward_slash_char] || '%2F'
    end

    def subject
      #  should be 'LAST' when we're loading a set of quickstatements for an object.
      # Should be the study's QCode when we're creating just one quickstatement per study
      @subject || 'LAST'
    end

    def prefix
      return "#{new_line}#{subject}#{tab}"
    end

    def create_all_quickstatements(id, file)
      obj = get_for(id)
      if obj and obj.should_be_loaded?
        file << 'CREATE'
        prop_codes.each{ |prop_code|
          file << quickstatement_for(prop_code)
        }
        file << " #{new_line}#{new_line}"
      end
    end

    def set_delimiters(args={})
      @delimiters = args[:delimiters]
      #@delimiters = {:new_line=>'||', :tab=>'|', :space_char=>'%20', :double_quote_char=>'%22', :forward_slash_char=>'%2F'} if @delimiters.blank?
      @delimiters = {:new_line=>'
', :tab=>'	', :space_char=>' ', :double_quote_char=>'"', :forward_slash_char=>'/'} if @delimiters.blank?
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

  end
end
