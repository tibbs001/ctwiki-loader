module Lookup
  class Intervention < SuperLookup
    self.table_name = 'lookup.interventions'

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
       'disease',
       'driving license',
       'drug allergy',
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
       'short story',
       'single by',
       'specialist',
       'store which sells nutrition supplements',
       'teleplay',
       'television series',
       'technical information service',
       'unincorporated community',
       'university',
       'watercourse',
       'webcomic',
       'extended play',
       'wikipedia',
       'zoroaster',
      ].flatten
    end

    def self.names_to_ignore
       ['walking, walking','quest', 'screen-educate and intensify treatment', 'computer-assisted counseling', 'computer-assisted gdft', 'computer-based clinical decision support.', 'computer-assisted cognitive training', 'computer-based alcohol reduction intervention', 'computer-based psychoeducational intervention', 'computer-based confrontation with dysfunctional beliefs', 'computer-based target pursuit task (created using e-prime software) and visual-feedback handgrip force transducer (currentdesigns 2012).', 'computer-facilitated hiv intervention',]
    end

    def self.possible_descriptions
      [
       'drug',
       'pharmaceutical drug',
       'device',
       'treatment',
       'treatment for a disease',
       'treatment for a medical condition',
       'intervention',
       'chemical compound',
      ]
    end

    def self.predefined_qcode
      {
        '1000 mg acetylsalicylic acid (Aspirin, BAYE4465)'          =>'Q18216',
        '500 mg acetylsalicylic acid (Aspirin, BAYE4465)'          =>'Q18216',
        'acetylsalicylic acid'          =>'Q18216',
        'acetylsalicylic acid 75 mg'          =>'Q18216',
        'acetylsalicylic acid (asa)'          =>'Q18216',
        'acetylsalicylic acid (asa) therapy'          =>'Q18216',
        'acetylsalicylic acid, clopidogrel bisulfate and/or warfarin, apixaban, rivaroxaban, dabigatran'          =>'Q18216',
        'acetylsalicylic acid started for 24 hours before surgery'          =>'Q18216',
        'acetylsalicylic acid stayed for 5 days before surgery'          =>'Q18216',
        'aspirin (acetylsalicylic acid)'          =>'Q18216',
        'association: acetylsalicylic acid (500mg), sodium bicarbonate (1625) and citric acid (965)'       =>'Q18216',
        'bausch & lomb renu multiplus multi-purpose solution' => 'Q50573431',
        'bausch & lomb multipurpose solution - no rub care' => 'Q50573431',
        'bausch & lomb renu multiplus multi-purpose solution packaged in the currently marketed resin bottle.' => 'Q50573431',

        'buffered acetylsalicylic acid'          =>'Q18216',
        'cardiovascular fixed dose combination pill (acetylsalicylic acid, simvastatin and ramipril)'          =>'Q18216',
        'cigarette'                              => 'Q1578',
        'clopidogrel+acetylsalicylic acid'       =>'Q18216',
        'inderal (drug), acetylsalicylic acid (drug)'          =>'Q18216',
        'nitric oxide-releasing acetylsalicylic acid derivative' =>'Q18216',
        'Simvastatin, ramipril, acetylsalicylic acid'           =>'Q18216',
        'azd6738 and olaparib'                   => 'Q27896182',
        'bevacizumab'                            => 'Q413299',
        'carboplatin'                            => 'Q415588',
        'celestamine'                            => 'Q59790585',
        'cheese'                                 => 'Q10943',  # NCT02836106
        'cisplatin'                              => 'Q412415',
        'cohort 2, ceplene and proleukin'        => 'Q29004963',
        'control'                                => 'Q2148398',
        'cyclophosphamide'                       => 'Q408524',
        'dexamethasone'                          => 'Q408524',
        'endurance training plus resistant training' => 'Q362854',
        'electrical impedance myography (eim)'   => 'Q5357720',
        'everolimus + letrozole'                 => 'Q421052',
        'first-line i/v-levetiracetam'           => 'Q26720719',  # NCT00603135
        'heat pad application'                   => 'Q59506412',
        'iv dexamethasone therapy'               => 'Q422252',
        'inv-144'                                => 'Q59795917',
        'laboratory biomarker analysis'          => 'Q59790130',  # already was biomarker (Q864574)  Added entity specifically for this
        'low frequency therapeutic ultrasound'   => 'Q59773581',  # added this treatment to wikidata
        'monthly ranibizumab'                    => 'Q414270',
        'msm'                                    => 'Q423842',
        'niacin/laropiprant/simvastatin (n/lrpt/sim)'  => 'Q134658',
        'half dose oxytocin'                     => 'Q169960',
        'paclitaxel'                             => 'Q423762',
        'phase ii - gm.cd40l.ccl21 vaccinations' => 'Q192995',
        '10 mg/kg IV phenobarbital in 100 ml saline'  => 'Q407241',
        'pimodivir'                              => 'Q27276370',
        'placebo'                                => 'Q269829',
        'placebo oral capsule'                   => 'Q269829',
        'placebos'                               => 'Q269829',
        'prp injection'                          => 'Q59791666',
        'pulpectomy for primary molars + 3mixstatin' => 'Q3410767',
        'radiation therapy'                      => 'Q180507',
        'rituximab'                              => 'Q412323',
        'r-mant'                                 => 'Q412323',  #  NCT02390869  other name for rituximab
        'st. johns wort'                         => 'Q156935',
        'tdm1'                                   =>'Q3997863',  # NCT02135159
        'trigonella foenum-graecum seed extract' => 'Q59773585',  #  added this treatment

     }
#     Q20459    | portable device used to generate a flame           | Cigarette

    end

  end
end
