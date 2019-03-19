module Lookup
  class Keyword < SuperLookup
    self.table_name = 'lookup.keywords'

    def self.names_to_ignore
      ['e-do', 'sade-free rate']
    end

    def self.possible_descriptions
      [
       'disease',
       'medical condition',
       'disorder',
       'defect',
       'disturbance',
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

    def self.predefined_qcode
      # Most common - ordered list.
      {
        'HIV'                                      => 'Q15787',
        'Obesity'                                  => 'Q12174',
        'Pharmacokinetics'                         => 'Q323936',
        'Depression'                               => 'Q42844',
        'Safety'                                   => 'Q10566551',
        'Cancer'                                   => 'Q12078',
        'Pain'                                     => 'Q81938',
        'Exercise'                                 => 'Q219067',
        'COPD'                                     => 'Q199804',
        'Diabetes'                                 => 'Q12206',
        'Quality of Life'                          => 'Q13100823',
        'Children'                                 => 'Q7569',
      }
    end
  end
end
