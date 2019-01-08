module Lookup
  class Keyword < SuperLookup
    self.table_name = 'lookup.keywords'

    def self.possible_descriptions
      [
       'disease',
       'medical condition',
       'disorder',
       'defect',
       'disturbance',
      ]
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
