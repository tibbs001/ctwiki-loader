module Lookup
  class Journal < SuperLookup
    self.table_name = 'lookup.journals'

    def self.source_data
      # The model that will be used as the source of info
      Pubmed::Publication
    end

    def self.predefined_qcode
      # Most common - ordered list.
      {
        'american journal of obstetrics and gynecology' => 'Q4744256',
        'anz journal of surgery'                        => 'Q15751460',
        'archives of dermatology'                       => 'Q27720869',
        'cancer'                                        =>'Q326041',
        'cancer research'                               => 'Q326097',
        'fertility and sterility'                       => 'Q15724525',
        'emergency medicine journal'                    => 'Q5370622',
        'international journal of cancer '              => 'Q332492',
        'neuroreport'                                   => 'Q15710007',
        'journal of anesthesia'                         => 'Q2308373',
        'journal of the american college of cardiology' =>'Q2984355',
        'journal of the american heart association'     => 'Q19880670',
        'nephrology, dialysis, transplantation : official publication of the european dialysis and transplant association - european renal association' => 'Q15710302',
      }
    end

    def self.possible_descriptions
      [
       'journal',
       'scientific journal',
       'academic journal',
       'hybrid open access journal',
      ]
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

  end

end
