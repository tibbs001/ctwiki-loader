module Lookup
  class Condition < SuperLookup
    self.table_name = 'lookup.conditions'

    def self.impossible_descriptions
      # Some descriptions are impossible for any model (they're defined in the superclass)
      # Combine those with the ones that are specifically impossible for conditions
      # but might be ok for organizations or interventions.
      super + [
        'abstract',
        'book',
        'clinical trial',
        'company',
        'doctoral thesis',
        'encryption device',
        'http://www.csb-ncss.org/index.html',
        'hospitals',
        'journal',
        'novel by',
        'occupational and environmental health',
        'organization',
        'orta to greater',
        'other organization',
        'person',
        'political party',
        'professional society',
        'report',
        'specialist',
        'storage device',
        'the ease of use and learnability of a human-made object such as a tool',
        'the transformation of one computational problem to another',
        'type of research',
        'washington',
        'weight of a vehicle without any consumables',
        'work by',
      ].flatten
    end

    def self.names_to_ignore
      ['auditory brainstem response', "children's safety", 'dna mutations', 'immobility']
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
        'abdominal aortic aneurysm, ruptured' => 'Q2256736',
        'bladder cancer'            => 'Q504775',
        'breast cancer'             => 'Q128581',
        'cancer'                    => 'Q12078',
        'colorectal cancer'         => 'Q188874',
        'coronary artery disease'   => 'Q844935',
        'diabetes'                  => 'Q12206',
        'diabetes mellitus, type 2' => 'Q3025883',
        'gastrointestinal endoscopy' => 'Q27723036',
        'glioma, astrocytic'        => 'Q1365309',
        'healthy'                   => 'Q24238419',
        'heart failure'             => 'Q181754',
        'hematologic disease'       => 'Q55785542',
        'her2 positive breast cancer, metastatic breast cancer, locally advanced breast cancer' => 'Q128581',
        'hiv infections'            => 'Q15787',
        'hypertension'              => 'Q41861',
        'lung cancer'               => 'Q47912',
        'obesity'                   => 'Q12174',
        'parkinsons'                => 'Q11085',
        'parkinsons disease'        => 'Q11085',
        'pediatric glaucoma'        => 'Q159701',
        'prostrate cancer'          => 'Q181257',
        'rheumatoid arthritis'      => 'Q187255',
        'schizophrenia'             => 'Q41112',
        'stroke'                    => 'Q12202',
      }
    end

  end
end
