module Lookup
  class Chemical < SuperLookup
    self.table_name = 'lookup.chemicals'

    def self.names_to_ignore
      ['e-do', 'sade-free rate']
    end

    def self.possible_descriptions
      [
       'class of drug',
       'chemical compound',
       'chemical element',
       'drug',
      ]
    end

    def self.source_data
      Pubmed::Chemical
    end

    def self.impossible_descriptions
      super + [
       'abstract',
       'actress',
       'airplane',
       'army general',
       'artillery guns',
       'artwork',
       'aviation squadron',
       'book',
       'brand of footwear',
       'clinical trial',
       'company',
       'conference',
       'driving license',
       'episode',
       'etching',
       'exhibition',
       'farmhouse',
       'galaxy',
       'governmental agency',
       'hospitals',
       'internet bank',
       'interpro family',
       'journal',
       'light table is a viewing device',
       'literature review',
       'mountain in',
       'non-profit',
       'norwegian',
       'organization',
       'motorway',
       'novel by',
       'person',
       'place for conducting research',
       'pokémon move',
       'presenter',
       'proposed ethernet standard',
       'publisher',
       'report',
       'rock band',
       'route',
       'rural commune',
       'scholarly article',
       'short story',
       'single by',
       'specialist',
       'store which sells nutrition supplements',
       'teleplay',
       'television series',
       'technical information service',
       'town in ',
       'unincorporated community',
       'university',
       'watercourse',
       'webcomic',
       'extended play',
       'wikipedia',
       'zoroaster',
      ].flatten
    end

    def self.predefined_qcode
      # Most common - ordered list.
      {
        'Antibodies, Viral' => 'Q66021534',
        'Cetylpyridinium' => 'Q27115152',
        'Chlorhexidine' => 'Q15646788',
        'DNA, Viral' =>        'Q64829422',
        'Hemoglobins'             => 'Q43041',
        'Papillomavirus Vaccines'  => 'Q900189',
        'Viral Vaccines'     => 'Q58624061',
        'Zinc' => 'Q758',
      }
    end
  end
end
