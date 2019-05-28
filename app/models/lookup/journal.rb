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
        'academic emergency medicine : official journal of the society for academic emergency medicine' => 'Q15755260',
        'academic medicine : journal of the association of american medical colleges' => 'Q15751327',
        'acta paediatrica (oslo, norway : 1992)'        => 'Q27718123',
        'acta radiologica (stockholm, sweden : 1987)'   => 'Q4033350',
        'addiction (abingdon, england)'                 => 'Q4681106',
        'advances in neonatal care : official journal of the national association of neonatal nurses' => 'Q4686388',
        'aging'                                         => 'Q2845875',
        'ajr. american journal of roentgenology'        => 'Q15752879',
        'alcoholism, clinical and experimental research' => 'Q4713331',
        'alcohol research & health : the journal of the national institute on alcohol abuse and alcoholism' => 'Q15753599',
        'allergy, asthma, and clinical immunology : official journal of the canadian society of allergy and clinical immunology' => 'Q15727057',
        'american journal of obstetrics and gynecology' => 'Q4744256',
        'amia ... annual symposium proceedings. amia symposium' => 'Q27720789',
        'annals of family medicine'                     => 'Q4767849',
        'annals of tropical paediatrics'                => 'Q4767871',
        'ajnr. american journal of neuroradiology'      => 'Q15762571',
        'anz journal of surgery'                        => 'Q15751460',
        'applied nursing research'                      => 'Q15755147',
        'archives of dermatology'                       => 'Q27720869',
        'cancer'                                        =>'Q326041',
        'cancer research'                               => 'Q326097',
        'endocrine practice : official journal of the american college of endocrinology' => 'Q15761577',
        'fertility and sterility'                       => 'Q15724525',
        'emergency medicine journal'                    => 'Q5370622',
        'international journal of cancer '              => 'Q332492',
        'neuroreport'                                   => 'Q15710007',
        'journal of anesthesia'                         => 'Q2308373',
        'journal of hand therapy : official journal of the american society of hand therapists' => 'Q15746463',
        'journal of intellectual disability research : jidr' => 'Q15757812',
        'journal of the american college of cardiology' =>'Q2984355',
        'journal of the american heart association'     => 'Q19880670',
        'nephrology, dialysis, transplantation : official publication of the european dialysis and transplant association - european renal association' => 'Q15710302',
        'revista espanola de enfermedades digestivas : organo oficial de la sociedad espanola de patologia digestiva' => 'Q26854018',
        'the journal of craniofacial surgery'          => 'Q15759095',
        'the journal of neuroscience : the official journal of the society for neuroscience' => 'Q1709864',
        'the journal of small animal practice' => 'Q15762435',
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
