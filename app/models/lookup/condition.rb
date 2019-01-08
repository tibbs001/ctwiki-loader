module Lookup
  class Condition < SuperLookup
    self.table_name = 'lookup.conditions'

    def self.impossible_descriptions
      # Some descriptions are impossible for any model (they're defined in the superclass)
      # Combine those with the ones that are specifically impossible for conditions
      # but might be ok for organizations or interventions.
      super + [ 'company', 'encryption device', 'hospitals', 'person', 'specialist', 'storage device'].flatten
    end

    def self.possible_descriptions
      [
       'condition',
       'disease',
       'problem',
       'disorder',
       'cancer',
       'carcinoma',
       'inability',
      ]
    end

    def self.predefined_qcode
      {
        'asthma'                    => 'Q35869',
        'breast cancer'             => 'Q128581',
        'cancer'                    => 'Q12078',
        'colorectal cancer'         => 'Q188874',
        'coronary artery disease'   => 'Q844935',
        'diabetes'                  => 'Q12206',
        'diabetes mellitus, type 2' => 'Q3025883',
        'glioma, astrocytic'        => 'Q1365309',
        'healthy'                   => 'Q24238419',
        'heart failure'             => 'Q181754',
        'her2 positive breast cancer, metastatic breast cancer, locally advanced breast cancer' => 'Q128581',
        'hiv infections'            => 'Q15787',
        'hypertension'              => 'Q41861',
        'lung cancer'               => 'Q47912',
        'obesity'                   => 'Q12174',
        'prostrate cancer'          => 'Q181257',
        'rheumatoid arthritis'      => 'Q187255',
        'schizophrenia'             => 'Q41112',
        'stroke'                    => 'Q12202',
      }
    end

  end
end
